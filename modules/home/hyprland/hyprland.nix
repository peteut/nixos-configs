{ lib, osConfig, ... }:
let
  cfg = osConfig.modules.hyprland;
  inherit (lib) mkIf;
in
{
  wayland.windowManager.hyprland = mkIf cfg.enable {
    enable = true;
    systemd.variables = [ "--all" ];
    package = null;
    portalPackage = null;
  };
  home.pointerCursor = mkIf cfg.enable {
    enable = true;
    hyprcursor.enable = true;
  };

  services = mkIf cfg.enable {
    hyprpolkitagent = {
      enable = true;
    };
    udiskie = {
      enable = true;
      automount = true;
      tray = "always";
    };
  };
}
