{ lib, osConfig, pkgs, ... }:
let
  inherit (builtins) attrValues;
in
{
  home.packages = lib.mkIf osConfig.modules.hyprland.enable (attrValues {
    inherit (pkgs)
      # Multimedia {{{
      pavucontrol
      pamixer
      # }}}
      # Display {{{
      brightnessctl
      # }}}
      # Office {{{
      calibre
      remmina
      slack
      joplin-desktop
      # }}}
      ;
  });
}
