{ pkgs, ... }:
{
  home.packages = builtins.attrValues {
    inherit (pkgs)
      # Multimedia {{{
      pavucontrol
      qpwgraph
      # }}}
      # Office {{{
      calibre
      remmina
      slack
      # teams
      joplin-desktop;
    # }}}
  };
}

