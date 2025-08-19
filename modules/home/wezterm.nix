{ lib, osConfig, pkgs, ... }:
let
  cfg = osConfig.modules.hyprland;
  inherit (lib) mkIf;
  inherit (pkgs) fetchFromGitHub;
  wezPainControl = {
    path = "wez-pain-control";
    source = fetchFromGitHub {
      owner = "sei40kr";
      repo = "wez-pain-control";
      rev = "main";
      sha256 = "sha256-GT4oeCF/FZJCRTiSzTV1Wt3EJ26Z90iUO/OqxmB1Ods=";
    };
  };
in
{
  programs.wezterm = mkIf cfg.enable {
    enable = true;
    extraConfig = ''
      local config = wezterm.config_builder()

      config.hide_tab_bar_if_only_one_tab = true
      config.mux_enable_ssh_agent = false
      config.disable_default_key_bindings = true
      config.keys = {
        { key = 'L', mods = 'CTRL', action = wezterm.action.ShowDebugOverlay },
        { key = 'c', mods = 'CTRL|SHIFT', action = wezterm.action.CopyTo 'Clipboard' },
        { key = 'v', mods = 'CTRL|SHIFT', action = wezterm.action.PasteFrom 'Clipboard' },
        { key = 'Enter', mods = 'ALT', action = wezterm.action.ToggleFullScreen },
      }
      config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 }
      require("${wezPainControl.path}.plugin").apply_to_config(config, {
        pane_resize = 2,
      })
      return config
    '';
  };
  xdg.configFile = {
    "wezterm/${wezPainControl.path}" = {
      inherit (wezPainControl) source;
    };
  };
}
