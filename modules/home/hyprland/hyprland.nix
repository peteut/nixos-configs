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
        wlsunset
        hyprland;
    };
    wayland.windowManager.hyprland = {
      enable = true;
      # set Hyperland and XDPH packagges to null, use them ones from th eNixOS module
      # package = null;
      # portalPackage = null;
      systemd.enable = true;
    };
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          igonore_dbus_inhibit = false;
          lock_cmd = "pidof hyprlock || hyprlock";
          unlock_cmd = "pkill --signal SIGUSR1 hyprlock";
          after_sleep_cmd = "hyprctl dispatch on";
          before_sleep_cmd = "loginctl lock-session";
        };

        listener = [
          {
            timeout = 300;
            on-timeout = "hyprlock";
          }
          {
            timeout = 360;
            on-timeout = "hyprctl dispatch dpm off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = 600;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
  };
}
