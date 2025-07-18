{ lib, ... }:
let
  splitToLines = s: lib.splitString "\n" s;
  terminal = "wezterm";
  browser = "google-chrome-stable";
in
{
  wayland.windowManager.hyprland = {
    settings = {
      exec-once = splitToLines ''
        dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
        systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

        waybar

        [workspace 1 silent] ${browser}
        [workspace 2 silent] ${terminal}
      '';
      input = {
        kb_layout = "ch";
      };

      general = {
        "$mainMod" = "SUPER";
        layout = "dwindle";
      };

      bind = splitToLines ''
        $mainMod, F1, exec, show-keybinds
        $mainMod, Return, exec, ${terminal}

        ALT, Return, exec, [float; size 1111 700] ${terminal}
        $mainMod SHIFT, Return, exec, [fullscreen] ${terminal}
        $mainMod, B, exec, [workspace 1 silent] ${browser}
      '';
    };
    extraConfig = ''
      monitor=,preferred,auto,auto

      xwayland {
        force_zero_scaling = true
      }
    '';
  };
}
