{ lib, config, pkgs, ... }:
let
  cfg = config.modules.logseqSync;
  inherit (lib) mkEnableOption mkIf mkOption types;

  svcUser = "logseq-sync";
  svcUid = 1501;
  home = "/home/${svcUser}";
  dataDir = "${home}/data";
  # The image runs as nonroot (65532); keep-id maps it to svcUser on the host
  # so dataDir stays owned by svcUser and backups can read it directly.
  imageUid = 65532;
  stagingDir = "${home}/backup-staging";
  resticPasswordFile = "${home}/restic.password";
  tsStateDir = "${home}/tailscale";
  # Holds TS_AUTHKEY=tskey-auth-... (mode 600, not in the store). Only used
  # for the first login (TS_AUTH_ONCE); the node key lives in tsStateDir.
  tsEnvFile = "${home}/tailscale.env";

  # Raw ipn.ServeConfig, as `tailscale serve --service=svc:<name>
  # --https=443 http://127.0.0.1:8787` would write it: TLS terminated by
  # tailscaled, proxied to the sync server in the shared network namespace.
  # Consistent copies of the live databases via SQLite's online backup API,
  # so the container keeps running. Runs as svcUser: opening the databases
  # as another user could leave -wal/-shm files the server cannot open.
  backupPrepare = pkgs.writeShellScript "logseq-sync-backup-prepare" ''
    set -euo pipefail
    sqlite3=${lib.getExe pkgs.sqlite}
    rm -rf ${stagingDir}
    mkdir -p ${stagingDir}/graphs
    $sqlite3 ${dataDir}/index.sqlite ".backup '${stagingDir}/index.sqlite'"
    n=0
    for db in ${dataDir}/graphs/*/db.sqlite; do
      [ -e "$db" ] || continue
      id=$(basename "$(dirname "$db")")
      mkdir -p ${stagingDir}/graphs/"$id"
      $sqlite3 "$db" ".backup '${stagingDir}/graphs/$id/db.sqlite'"
      n=$((n + 1))
    done
    # A backup without any graph is almost certainly wrong (layout change,
    # nothing synced yet); fail the unit instead of snapshotting nothing.
    if [ "$n" -eq 0 ]; then
      echo "no graph databases found under ${dataDir}/graphs" >&2
      exit 1
    fi
    echo "staged $n graph database(s)"
  '';

  serveConfig = pkgs.writeText "logseq-serve.json" (builtins.toJSON {
    Services."svc:${cfg.serviceName}" = {
      TCP."443".HTTPS = true;
      Web."${cfg.serviceName}.${cfg.tailnet}:443".Handlers."/".Proxy =
        "http://127.0.0.1:8787";
    };
  });
in
{
  options.modules.logseqSync = {
    enable = mkEnableOption "self-hosted Logseq DB sync server in rootless podman";

    image = mkOption {
      type = types.str;
      # pin, bump deliberately; tags are YYYYMMDD-<upstream ref>
      default = "ghcr.io/yshalsager/logseq-selfhost-sync:20261010-e88658a";
      description = "Container image of the sync server.";
    };

    port = mkOption {
      type = types.port;
      default = 8787;
      description = "Port published on 127.0.0.1 only.";
    };

    tailnet = mkOption {
      type = types.str;
      example = "tail1234.ts.net";
      description = "MagicDNS suffix of the tailnet.";
    };

    serviceName = mkOption {
      type = types.str;
      default = "logseq";
      description = "Tailscale Service (svc:<name>) hosted by the sidecar node.";
    };

    baseUrl = mkOption {
      type = types.str;
      default = "https://${cfg.serviceName}.${cfg.tailnet}";
      defaultText = lib.literalExpression ''"https://''${serviceName}.''${tailnet}"'';
      description = ''
        Public URL of the sync server (DB_SYNC_BASE_URL). Must match the
        Sync Server URL configured in every Logseq client.
      '';
    };

    backup.repository = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "/mnt/c/Users/me/OneDrive/backup/logseq-sync";
      description = ''
        restic repository for daily backups of the sync server data, or null
        to disable. The password is read from ${resticPasswordFile}.
      '';
    };

    sidecar = {
      image = mkOption {
        type = types.str;
        default = "docker.io/tailscale/tailscale:v1.104.1"; # pin, bump deliberately
        description = "Tailscale image of the sidecar node.";
      };

      hostname = mkOption {
        type = types.str;
        default = "svc-${config.networking.hostName}";
        defaultText = lib.literalExpression ''"svc-''${config.networking.hostName}"'';
        description = "Tailnet device name of the sidecar node.";
      };

      tags = mkOption {
        type = types.listOf types.str;
        default = [ "tag:server" ];
        description = ''
          Tags of the sidecar node; Service hosts need a tag-based identity.
          Must match the tags of the auth key.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [{
      # home-manager is imported and configured by modules.user.
      assertion = config.modules.user.enable;
      message = "modules.logseqSync requires modules.user.enable (home-manager).";
    }];

    users.users."${svcUser}" = {
      isNormalUser = true;
      group = "${svcUser}";
      description = "Logseq sync server";
      uid = svcUid;
      linger = true; # keep the container running without a login session
      shell = pkgs.bash;
    };

    users.groups."${svcUser}" = { };

    # Rootless podman needs the system part: newuidmap/newgidmap wrappers
    # and /etc/containers policy.
    virtualisation.podman.enable = true;

    systemd.tmpfiles.rules = [
      "d ${dataDir} 0750 ${svcUser} ${svcUser} -"
      "d ${tsStateDir} 0700 ${svcUser} ${svcUser} -"
    ];

    services.restic.backups.logseq-sync = mkIf (cfg.backup.repository != null) {
      user = svcUser;
      inherit (cfg.backup) repository;
      passwordFile = resticPasswordFile;
      initialize = true;
      backupPrepareCommand = "${backupPrepare}";
      backupCleanupCommand = "rm -rf ${stagingDir}";
      # Staged database copies plus everything else in dataDir (assets),
      # minus the live databases.
      paths = [ stagingDir dataDir ];
      exclude = [
        "${dataDir}/**/*.sqlite"
        "${dataDir}/**/*.sqlite-wal"
        "${dataDir}/**/*.sqlite-shm"
      ];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 6"
        "--keep-yearly 1"
      ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true; # catch up at next boot if desktop was off
        RandomizedDelaySec = "1h";
      };
    };

    home-manager.users."${svcUser}" = {
      home = {
        username = "${svcUser}";
        stateVersion = "26.05";
        homeDirectory = home;
      };

      services.podman = {
        enable = true;
        containers.logseq-sync = {
          autoStart = true;
          image = cfg.image;
          ports = [ "127.0.0.1:${toString cfg.port}:8787" ];
          userNS = "keep-id:uid=${toString imageUid},gid=${toString imageUid}";
          volumes = [ "${dataDir}:/app/data" ];
          environment = {
            DB_SYNC_PORT = "8787";
            DB_SYNC_BASE_URL = cfg.baseUrl;
            DB_SYNC_DATA_DIR = "/app/data";
            DB_SYNC_STORAGE_DRIVER = "sqlite";
            DB_SYNC_ASSETS_DRIVER = "filesystem";
            DB_SYNC_LOG_LEVEL = "info";
            # Logseq's Cognito pool, used to validate client JWTs.
            COGNITO_ISSUER = "https://cognito-idp.us-east-1.amazonaws.com/us-east-1_dtagLnju8";
            COGNITO_CLIENT_ID = "69cs1lgme7p8kbgld8n5kseii6";
            COGNITO_JWKS_URL = "https://cognito-idp.us-east-1.amazonaws.com/us-east-1_dtagLnju8/.well-known/jwks.json";
          };
          # Upstream hardening: read-only rootfs, no caps, no privilege gain.
          dropCapabilities = [ "ALL" ];
          extraConfig = {
            Container = {
              ReadOnly = true;
              NoNewPrivileges = true;
              Tmpfs = "/tmp";
            };
            # Bring the sidecar back whenever this container (and with it
            # the shared network namespace) is restarted.
            Unit.Upholds = "podman-logseq-tailscale.service";
          };
        };

        # Sidecar tailnet node: a tagged identity of its own hosting
        # svc:<serviceName>, so desktop itself stays a user-owned device.
        # Userspace networking, so no TUN device is needed.
        containers.logseq-tailscale = {
          autoStart = true;
          image = cfg.sidecar.image;
          network = "container:logseq-sync";
          volumes = [
            "${tsStateDir}:/var/lib/tailscale"
            "${serveConfig}:/config/serve.json:ro"
          ];
          environmentFile = [ tsEnvFile ];
          environment = {
            TS_HOSTNAME = cfg.sidecar.hostname;
            TS_STATE_DIR = "/var/lib/tailscale";
            TS_USERSPACE = "true";
            TS_AUTH_ONCE = "true";
            TS_SERVE_CONFIG = "/config/serve.json";
            TS_EXTRA_ARGS = "--advertise-tags=${lib.concatStringsSep "," cfg.sidecar.tags}";
          };
          extraConfig = {
            Container.NoNewPrivileges = true;
            Unit = {
              BindsTo = "podman-logseq-sync.service";
              After = "podman-logseq-sync.service";
            };
          };
        };
      };
    };
  };
}
