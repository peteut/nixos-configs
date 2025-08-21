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
      enable = true;
    };

    networking.firewall = {
      enable = true;
      checkReversePath = "loose";
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
    };
  };
}
