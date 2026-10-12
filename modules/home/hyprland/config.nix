{ lib, ... }:
let
  inherit (lib.generators) mkLuaInline toLua;
  lua = toLua { };

  terminal = "wezterm";
  browser = "librewolf";
  uwsm = cmd: "uwsm app -- ${cmd}";
  noctalia = cmd: "noctalia msg ${cmd}";

  # Docked at work: two Dell U2414H left of the X1's panel.
  dellLeft = "desc:Dell Inc. DELL U2414H X4J7181T1P4L";
  dellRight = "desc:Dell Inc. DELL U2414H X4J7181T1P6L";

  # hl.bind(key, action[, opts]); `action` is a raw Lua expression.
  bind = key: action: { _args = [ key (mkLuaInline action) ]; };
  bindOpts = key: action: opts: { _args = [ key (mkLuaInline action) opts ]; };
  # hl.dsp.exec_cmd(cmd[, rule])
  exec = cmd: "hl.dsp.exec_cmd(${lua cmd})";
  execRule = cmd: rule: "hl.dsp.exec_cmd(${lua cmd}, ${lua rule})";
  # Media/brightness keys keep working on the lock screen and auto-repeat.
  mediaKey = { locked = true; repeating = true; };

  # Move focus, then raise the window (former movefocus + alterzorder pair).
  focusRaise = key: direction: bind "SUPER + ${key}" ''
    function()
      hl.dispatch(hl.dsp.focus({ direction = ${lua direction} }))
      hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
    end'';

  workspaceBinds = lib.concatMap
    (i:
      let key = toString (lib.mod i 10); in
      [
        (bind "SUPER + ${key}" "hl.dsp.focus({ workspace = ${toString i} })")
        (bind "SUPER + SHIFT + ${key}"
          "hl.dsp.window.move({ workspace = ${toString i}, follow = false })")
      ])
    (lib.range 1 10);

  persistentWorkspace = monitor: i: {
    workspace = toString i;
    inherit monitor;
    persistent = true;
  };
in
{
  gtk.enable = true;
  qt.enable = true;
  wayland.windowManager.hyprland = {
    configType = "lua";
    settings = {
      monitor = [
        { output = ""; mode = "preferred"; position = "auto"; scale = "1.0"; }
        { output = dellLeft; mode = "1920x1080"; position = "0x120"; scale = "1.0"; }
        { output = dellRight; mode = "1920x1080"; position = "1920x120"; scale = "1.0"; }
        { output = "eDP-1"; mode = "1920x1200"; position = "3840x0"; scale = "1.2"; }
      ];

      config = {
        input.kb_layout = "ch";
        xwayland.force_zero_scaling = true;

        # Look & feel recommended by Noctalia; border/shadow colours come
        # from stylix.
        general = {
          layout = "dwindle";
          gaps_in = 5;
          gaps_out = 10;
        };
        decoration = {
          rounding = 12;
          rounding_power = 2;
          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
          };
          blur = {
            enabled = true;
            size = 3;
            passes = 2;
            vibrancy = 0.1696;
          };
        };
      };

      # Pinned when docked; Hyprland falls back to an available monitor when
      # a Dell is absent (laptop only).
      workspace_rule =
        map (persistentWorkspace dellLeft) [ 1 2 3 ]
        ++ map (persistentWorkspace dellRight) [ 4 5 ];

      window_rule = [
        {
          name = "noctalia-settings";
          match.class = "dev.noctalia.Noctalia";
          float = true;
          size = [ 1080 920 ];
        }
      ];

      # Blur Noctalia surfaces, leave animations to Noctalia itself.
      layer_rule = [
        {
          name = "noctalia";
          match.namespace =
            "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$";
          no_anim = true;
          ignore_alpha = 0.5;
          blur = true;
          blur_popups = true;
        }
      ];

      on = {
        _args = [
          "hyprland.start"
          (mkLuaInline ''
            function()
              hl.exec_cmd(${lua (uwsm "noctalia")})
              hl.exec_cmd(${lua (uwsm browser)}, { workspace = "1 silent" })
              hl.exec_cmd(${lua (uwsm terminal)}, { workspace = "2 silent" })
            end'')
        ];
      };

      bind = [
        (bind "SUPER + F1" (exec "show-keybinds"))
        (bind "SUPER + Return" (exec terminal))
        (bind "ALT + Return" (execRule (uwsm terminal) { float = true; size = [ 1111 700 ]; }))
        (bind "SUPER + SHIFT + Return" (execRule (uwsm terminal) { fullscreen = true; }))
        (bind "SUPER + B" (execRule (uwsm browser) { workspace = "1 silent"; }))
        (bind "SUPER + Q" "hl.dsp.window.close()")
        (bind "SUPER + F" ''hl.dsp.window.fullscreen({ mode = "fullscreen" })'')
        (bind "SUPER + SHIFT + F" ''hl.dsp.window.fullscreen({ mode = "maximized" })'')
        (bind "SUPER + Space" ''hl.dsp.window.float({ action = "toggle" })'')
        (bind "ALT + Escape" (exec "loginctl lock-session"))

        # Noctalia
        (bind "SUPER + R" (exec (noctalia "panel-toggle launcher")))
        (bind "SUPER + S" (exec (noctalia "panel-toggle control-center")))
        (bind "SUPER + comma" (exec (noctalia "settings-toggle")))
        (bind "ALT + Tab" (exec (noctalia "window-switcher hold")))

        (focusRaise "h" "left")
        (focusRaise "j" "down")
        (focusRaise "k" "up")
        (focusRaise "l" "right")

        (bind "SUPER + CTRL + c" ''hl.dsp.window.move({ workspace = "empty" })'')

        (bindOpts "XF86AudioRaiseVolume" (exec (noctalia "volume-up")) mediaKey)
        (bindOpts "XF86AudioLowerVolume" (exec (noctalia "volume-down")) mediaKey)
        (bindOpts "XF86AudioMute" (exec (noctalia "volume-mute")) { locked = true; })
        (bindOpts "XF86AudioMicMute" (exec (noctalia "mic-mute")) { locked = true; })
        (bindOpts "XF86MonBrightnessUp" (exec (noctalia "brightness-up")) mediaKey)
        (bindOpts "XF86MonBrightnessDown" (exec (noctalia "brightness-down")) mediaKey)

        (bindOpts "SUPER + mouse:272" "hl.dsp.window.drag()" { mouse = true; })
        (bindOpts "SUPER + mouse:273" "hl.dsp.window.resize()" { mouse = true; })
      ]
      ++ workspaceBinds;
    };
  };
}
