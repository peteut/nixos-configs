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

    baseUrl = mkOption {
      type = types.str;
      example = "https://desktop.example.ts.net";
      description = ''
        Public URL of the sync server (DB_SYNC_BASE_URL). Must match the
        Sync Server URL configured in every Logseq client.
      '';
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
    ];

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
          extraConfig.Container = {
            ReadOnly = true;
            NoNewPrivileges = true;
            Tmpfs = "/tmp";
          };
        };
      };
    };
  };
}
