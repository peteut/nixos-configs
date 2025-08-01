{ lib, osConfig, ... }:
let
  cfg = osConfig.modules.hyprland;
  inherit (lib) mkIf;
in
{
  services.wlsunset = mkIf cfg.enable {
    enable = true;
    latitude = 47;
    longitude = 7;
  };
}
