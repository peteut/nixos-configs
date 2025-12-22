{ pkgs, ... }:
let
  inherit (builtins) attrValues;
in
{
  home.packages = attrValues {
    inherit (pkgs)
      # Multimedia {{{
      pavucontrol
      qpwgraph
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

