{ ... }:
let
  font = "JetBrainsMono Nerd Font";
in
{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = wezterm.config_builder()

      config.color_scheme = "Nord (base16)"
      config.font = wezterm.font "${font}"
      config.hide_tab_bar_if_only_one_tab = true
      config.mux_enable_ssh_agent = false
      config.keys = {
        {
          key = "f",
          mods = "CTRL",
          action="ToggleFullScreen"
        },
      }
      return config
    '';
  };
}
