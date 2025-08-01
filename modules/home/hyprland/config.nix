{ lib, ... }:
let
  terminal = "wezterm";
  splitToLines = s: lib.splitString "\n" s;
  browser = "google-chrome-stable";
  uwsmPrefix = "uwsm app --";
in
{
  gtk.enable = true;
  wayland.windowManager.hyprland = {
    settings = {
      exec-once = splitToLines ''
        [workspace 1 silent] ${uwsmPrefix} ${browser}
        [workspace 2 silent] ${uwsmPrefix} ${terminal}
      '';
      input = {
        kb_layout = "ch";
      };

      general = {
        layout = "dwindle";
      };

      bind = [
        "SUPER, F1, exec, show-keybinds"
        "SUPER, Return, exec, ${terminal}"

        "ALT, Return, exec, [float; size 1111 700] ${uwsmPrefix} ${terminal}"
        "SUPER SHIFT, Return, exec, [fullscreen] ${uwsmPrefix} ${terminal}"
        "SUPER, B, exec, [workspace 1 silent] ${uwsmPrefix} ${browser}"
        "SUPER, Q, killactive,"
        "SUPER, F, fullscreen, 0"
        "SUPER SHIFT, F, fullscreen, 1"
        "SUPER, Space, exec, ${uwsmPrefix} togglefloating"
        "ALT, Escape, exec, ${uwsmPrefix} loginctl lock-session"
        "SUPER, R, exec, ${uwsmPrefix} wofi --show run --prompt=Run --term=${terminal}"

        # switch focus
        "SUPER, h, movefocus, l"
        "SUPER, j, movefocus, d"
        "SUPER, k, movefocus, u"
        "SUPER, l, movefocus, r"

        "SUPER, h, alterzorder, top"
        "SUPER, j, alterzorder, top"
        "SUPER, k, alterzorder, top"
        "SUPER, l, alterzorder, top"

        # switch workspace
        "SUPER, 1, workspace, 1"
        "SUPER, 2, workspace, 2"
        "SUPER, 3, workspace, 3"
        "SUPER, 4, workspace, 4"
        "SUPER, 5, workspace, 5"
        "SUPER, 6, workspace, 6"
        "SUPER, 7, workspace, 7"
        "SUPER, 8, workspace, 8"
        "SUPER, 9, workspace, 9"
        "SUPER, 0, workspace, 10"

        # same as above, but switch to the workspace
        "SUPER SHIFT, 1, movetoworkspacesilent, 1" # movetoworkspacesilent
        "SUPER SHIFT, 2, movetoworkspacesilent, 2"
        "SUPER SHIFT, 3, movetoworkspacesilent, 3"
        "SUPER SHIFT, 4, movetoworkspacesilent, 4"
        "SUPER SHIFT, 5, movetoworkspacesilent, 5"
        "SUPER SHIFT, 6, movetoworkspacesilent, 6"
        "SUPER SHIFT, 7, movetoworkspacesilent, 7"
        "SUPER SHIFT, 8, movetoworkspacesilent, 8"
        "SUPER SHIFT, 9, movetoworkspacesilent, 9"
        "SUPER SHIFT, 0, movetoworkspacesilent, 10"
        "SUPER CTRL, c, movetoworkspace, empty"

        # Volume / brightness
        ",XF86AudioRaiseVolume, exec, ${uwsmPrefix} pamixer -i 5"
        ",XF86AudioLowerVolume, exec, ${uwsmPrefix} pamixer -d 5"
        ",XF86AudioMute, exec, ${uwsmPrefix} pamixer -t"
        ",XF86AudioMicMute, exec, ${uwsmPrefix} pamixer -m"

        ",XF86MonBrightnessUp, exec, ${uwsmPrefix} brightnessctl s 5%+"
        ",XF86MonBrightnessDown, exec, ${uwsmPrefix} brightnessctl s 5%-"
      ];

      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];
    };
    extraConfig = ''
      monitor = , preferred, auto, 1.0
      monitor = desc:Dell Inc. DELL U2414H X4J7181T1P4L, 1920x1080, 0x120, 1.0
      monitor = desc:Dell Inc. DELL U2414H X4J7181T1P6L, 1920x1080, 1920x120, 1.0
      monitor = eDP-1, 1920x1200, 3840x0, 1.2

      xwayland {
        force_zero_scaling = true
      }
    '';
  };
}
