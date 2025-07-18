{ lib, pkgs, modules-config, ... }:
let
  cfg = modules-config.hyprland;
  inherit (lib) mkIf attrValues;
  terminal = "wezterm";
in
{
  config = mkIf cfg.enable {
    home.packages = attrValues {
      inherit (pkgs)
        wl-clip-persist
        cliphist
        swww
        wayland;
    };
    wayland.windowManager.hyprland = {
      enable = true;
      # set Hyperland and XDPH packagges to null, use them ones from th eNixOS module
      # package = null;
      # portalPackage = null;
      systemd.enable = true;
    };
  };
}
