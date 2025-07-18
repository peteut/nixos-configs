{ pkgs, ... }:
let
  inherit (builtins) attrValues;
in
{
  home.packages = attrValues {
    inherit (pkgs)
      # multimedia {{{
      pamixer
      # {{{
      # display {{{
      brightnessctl
      # }}}
      # filemanager {{{
      yazi
      # }}}
      ;
  };
}
