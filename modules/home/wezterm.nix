{ pkgs, ... }:
let
  inherit (pkgs) fetchFromGitHub;
  wezPainControl = {
    path = "wez-pain-control";
    source = fetchFromGitHub {
      owner = "sei40kr";
      rev = "main";
      repo = "wez-pain-control";
      sha256 = "sha256-GT4oeCF/FZJCRTiSzTV1Wt3EJ26Z90iUO/OqxmB1Ods=";
    };
  };

in
{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local config = wezterm.config_builder()

      config.hide_tab_bar_if_only_one_tab = true
      config.mux_enable_ssh_agent = false
      config.keys = {
      }
      config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 }
      require("${wezPainControl.path}.plugin").apply_to_config(config, {})
      return config
    '';
  };
  xdg.configFile = {
    "wezterm/${wezPainControl.path}" = {
      inherit (wezPainControl) source;
    };
  };
}
