{ lib, config, pkgs, ... }:
let
  cfg = config.modules.tailscale;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.modules.tailscale = {
    enable = mkEnableOption "tailscale";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = builtins.attrValues {
      inherit (pkgs) tailscale;
    };

    services.tailscale = {
      enable = true;
      extraUpFlags = [ "--ssh" ];
    };

    networking.firewall = {
      enable = true;
      checkReversePath = "loose";
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
    };
  };
}
