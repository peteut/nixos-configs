{ lib, config, pkgs, ... }:
let
  cfg = config.modules.tailscale;
  inherit (lib) mkEnableOption mkIf mkOption types;
in
{
  options.modules.tailscale = {
    enable = mkEnableOption "tailscale";
    useRoutingFeatures = mkOption {
      default = "client";
      type = types.str;
      example = "server";
    };
    extraUpFlags = mkOption {
      default = [ "--ssh" ];
      type = types.lines;
      example = [ "--ssh" ];
    };
    resolved = mkOption { default = true; example = false; type = types.bool; };
    services = mkOption {
      default = { };
      description = ''
        Tailscale Services hosted on this node, each reachable as
        https://<name>.<tailnet>.ts.net. The node must carry a tag that is
        allowed to host the service, and the service must be defined (and
        approved) in the admin console.
      '';
      example = { logseq.target = "http://127.0.0.1:8787"; };
      type = types.attrsOf (types.submodule {
        options = {
          httpsPort = mkOption {
            type = types.port;
            default = 443;
            description = "HTTPS port of the service, TLS terminated by tailscaled.";
          };
          target = mkOption {
            type = types.str;
            example = "http://127.0.0.1:8787";
            description = "Local backend the service proxies to.";
          };
        };
      });
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = builtins.attrValues {
      inherit (pkgs) tailscale;
    };

    services.tailscale = {
      enable = true;
      extraUpFlags = cfg.extraUpFlags;
      useRoutingFeatures = cfg.useRoutingFeatures;
    };

    services.resolved = {
      enable = cfg.resolved;
    };

    networking.firewall = {
      enable = true;
      checkReversePath = "loose";
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
    };

    # One oneshot unit per service using the serve CLI. The upstream
    # services.tailscale.serve module (set-config) cannot yet terminate TLS
    # in front of a plain HTTP backend: "http://" targets give a plain HTTP
    # listener and "tls-terminated-tcp://" is rejected by tailscale <= 1.104.
    # Switch to it once a release carries the fix; the URLs stay the same.
    systemd.services = lib.mapAttrs'
      (name: svc:
        let
          tailscale = lib.getExe config.services.tailscale.package;
        in
        lib.nameValuePair "tailscale-serve-${name}" {
          description = "Tailscale Service svc:${name}";
          after = [ "tailscaled.service" "tailscaled-autoconnect.service" ];
          wants = [ "tailscaled.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            # Start from a clean slate so changed ports/targets don't pile up.
            ExecStartPre = "-${tailscale} serve clear svc:${name}";
            ExecStart = "${tailscale} serve --service=svc:${name} --https=${toString svc.httpsPort} ${svc.target}";
            ExecStop = "${tailscale} serve clear svc:${name}";
            # tailscaled may not be logged in yet right after boot.
            Restart = "on-failure";
            RestartSec = 10;
          };
        })
      cfg.services;
  };
}
