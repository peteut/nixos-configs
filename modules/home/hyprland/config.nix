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
        wlsunset -l 47 -L 7
        hypridle
        dunst

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

      bind = [
        "$mainMod, F1, exec, show-keybinds"
        "$mainMod, Return, exec, ${terminal}"

        "ALT, Return, exec, [float; size 1111 700] ${terminal}"
        "$mainMod SHIFT, Return, exec, [fullscreen] ${terminal}"
        "$mainMod, B, exec, [workspace 1 silent] ${browser}"
        "$mainMod, Q, killactive,"
        "$mainMod, F, fullscreen, 0"
        "$mainMod SHIFT, F, fullscreen, 1"
        "$mainMod, Space, exec, togglefloating"
        "ALT, Escape, exec, hyprlock"
        "$mainMod, R, exec, wofi --show run --prompt=Run --term=${terminal}"

        # switch focus
        "$mainMod, h, movefocus, l"
        "$mainMod, j, movefocus, d"
        "$mainMod, k, movefocus, u"
        "$mainMod, l, movefocus, r"

        "$mainMod, h, alterzorder, top"
        "$mainMod, j, alterzorder, top"
        "$mainMod, k, alterzorder, top"
        "$mainMod, l, alterzorder, top"

        # switch workspace
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # same as above, but switch to the workspace
        "$mainMod SHIFT, 1, movetoworkspacesilent, 1" # movetoworkspacesilent
        "$mainMod SHIFT, 2, movetoworkspacesilent, 2"
        "$mainMod SHIFT, 3, movetoworkspacesilent, 3"
        "$mainMod SHIFT, 4, movetoworkspacesilent, 4"
        "$mainMod SHIFT, 5, movetoworkspacesilent, 5"
        "$mainMod SHIFT, 6, movetoworkspacesilent, 6"
        "$mainMod SHIFT, 7, movetoworkspacesilent, 7"
        "$mainMod SHIFT, 8, movetoworkspacesilent, 8"
        "$mainMod SHIFT, 9, movetoworkspacesilent, 9"
        "$mainMod SHIFT, 0, movetoworkspacesilent, 10"
        "$mainMod CTRL, c, movetoworkspace, empty"

        # Volume / brightness
        ",XF86AudioRaiseVolume, exec, pamixer -i 5"
        ",XF86AudioLowerVolume, exec, pamixer -d 5"
        ",XF86AudioMute, exec, pamixer -t"
        ",XF86AudioMicMute, exec, pamixer -m"

        ",XF86MonBrightnessUp, exec, brightnessctl s 5%+"
        ",XF86MonBrightnessDown, exec, brightnessctl s 5%-"
      ];
    };
    extraConfig = ''
      monitor=,preferred,auto,auto

      xwayland {
        force_zero_scaling = true
      }
    '';
  };
}
