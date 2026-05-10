{ pkgs, ... }:
let
  inherit (builtins) attrValues;
in
{
  home.packages = attrValues {
    inherit (pkgs)
      # Multimedia {{{
      pavucontrol
      # }}}
      # Office {{{
      calibre
      remmina
      slack
      joplin-desktop
      # }}}
      ;
  };
}

