{ pkgs, pkgsUnstable, ... }:
let
  inherit (builtins) attrValues;
in
{
  home.packages = attrValues {
    inherit (pkgs)
      # filemanager {{{
      yazi
      # }}}
      # nix helper {{{
      nh
      # }}}
      ;
    inherit (pkgsUnstable)
      # devenv {{{
      devenv
      # }}}
      ;
  };
}
