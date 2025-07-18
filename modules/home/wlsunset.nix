{ lib, osConfig, ... }:
let
  cfg = osConfig.modules.hyprland;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    services.wlsunset = {
      enable = true;
      latitude = 47;
      longitude = 7;
    };
  };
}
