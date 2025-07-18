{ lib, pkgs, ... }:
{
  programs.hyprlock = {
    enable = true;
    package = pkgs.hyprlock;
    settings = {
      disable_loading_bar = true;
      hide_cursor = true;
      no_fade_in = false;
    };
  };
}
