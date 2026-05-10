{ lib, osConfig, ... }:
let
  cfg = osConfig.modules.hyprland;
  inherit (lib) mkIf;
in
{
  services.dunst = mkIf cfg.enable {
    enable = false;
    settings = {
      global = {
        origin = "top-left";
        timeout = 2;
      };
    };
  };
}
