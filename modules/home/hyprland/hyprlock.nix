{ lib, ... }:
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor = true;
        no_fade_in = false;
        enable_fingerprint = true;
      };
      auth = {
        fingerprint = {
          enabled = true;
        };
      };
    };
  };
}
