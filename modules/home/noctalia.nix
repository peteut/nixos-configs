{ lib, osConfig, inputs, ... }:
let
  cfg = osConfig.modules.hyprland;
  inherit (lib) mkIf;
in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];
  # Noctalia v5 is the single shell layer: bar, launcher, notifications,
  # clipboard history, OSDs, night light, idle handling and the session lock.
  # Hence no waybar/wofi/dunst/wlsunset/cliphist/hypridle/hyprlock.
  programs.noctalia = mkIf cfg.enable {
    enable = true;
    # Started by Hyprland via `exec-once` (uwsm), see hyprland/config.nix.
    systemd.enable = false;
    settings = {
      shell = {
        date_format = "%A, %d.%m.%Y";
      };
      bar.main = {
        position = "bottom";
        # v4 `density = "compact"` has no direct v5 equivalent.
        thickness = 28;
      };
      location.address = "Bern, Switzerland";

      lockscreen = {
        enabled = true;
        # Lock on logind PrepareForSleep (lid close / systemctl suspend),
        # formerly hypridle's before_sleep_cmd.
        lock_before_suspend = true;
        # PAM `login` service; fprintd is enabled on x1.
        fingerprint = true;
      };

      # Former hypridle listeners.
      idle = {
        behavior_order = [ "dim" "kbd-backlight" "lock" "screen-off" "suspend" ];
        behavior = {
          dim = {
            timeout = 150;
            action = "command";
            command = "brightnessctl -s s 10%";
            resume_command = "brightnessctl -r";
          };
          kbd-backlight = {
            timeout = 150;
            action = "command";
            command = "brightnessctl -sd tpacpi::kbd_backlight set 0";
            resume_command = "brightnessctl -rd tpacpi::kbd_backlight";
          };
          lock = {
            timeout = 300;
            action = "lock";
            enabled = true;
          };
          screen-off = {
            timeout = 360;
            action = "screen_off";
            enabled = true;
          };
          suspend = {
            timeout = 600;
            # Suspend on battery only; locking is covered by lock_before_suspend.
            action = "command";
            command = "systemd-ac-power || systemctl suspend";
          };
        };
      };
    };
  };
}
