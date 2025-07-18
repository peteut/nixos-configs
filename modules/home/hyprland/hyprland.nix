{ lib, osConfig, ... }:
let
  cfg = osConfig.modules.hyprland;
  inherit (lib) mkIf;
  uwsmPrefix = "uwsm app --";
  lockCmd = "pidof hyprlock || hyprlock";
  unlockCmd = "pkill --signal SIGUSR1 hyprlock";
in
{
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.variables = [ "--all" ];
    };
    home.pointerCursor = {
      enable = true;
      hyprcursor.enable = true;
    };
    services = {
      hypridle = {
        enable = true;
        settings = {
          general = {
            ignore_dbus_inhibit = false;
            lock_cmd = "${uwsmPrefix} ${lockCmd}";
            unlock_cmd = "${uwsmPrefix} ${unlockCmd}";
            after_sleep_cmd = "${uwsmPrefix} hyprctl dispatch dpms on";
            before_sleep_cmd = "${uwsmPrefix} ${lockCmd}";
          };

          listener = [
            {
              timeout = 300;
              on-timeout = "${uwsmPrefix} ${lockCmd}";
            }
            {
              timeout = 360;
              on-timeout = "${uwsmPrefix} hyprctl dispatch dpms off";
              on-resume = "${uwsmPrefix} hyprctl dispatch dpms on";
            }
            {
              timeout = 600;
              on-timeout = "${uwsmPrefix} systemd-ac-power || ${uwsmPrefix} systemctl suspend";
            }
            {
              timeout = 150;
              on-timeout = "${uwsmPrefix} brightnessctl -s s 10%";
              on-resume = "${uwsmPrefix} brightnessctl -r";
            }
            {
              timeout = 150;
              on-timeout = "${uwsmPrefix} brightnessctl -sd tpacpi::kbd_backlight set 0";
              on-resume = "${uwsmPrefix} brightnessctl -rd tpacpi::kbd_backlight";
            }
          ];
        };
      };
      hyprpolkitagent = {
        enable = true;
      };
      cliphist = {
        enable = true;
      };
    };
  };
}
