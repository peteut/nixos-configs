{ pkgs, ... }:
let
  inherit (builtins) attrValues;
in
{
  home.packages = attrValues {
    inherit (pkgs) wofi;
  };
  programs.wofi = {
    enable = true;
    style = ''
      * {
        font-family: monspace;
       }
    '';
  };
}
