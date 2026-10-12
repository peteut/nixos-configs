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
      ;
    inherit (pkgsUnstable)
      # devenv {{{
      devenv
      # }}}
      ;
  };
}
