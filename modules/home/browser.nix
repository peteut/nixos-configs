{ pkgs, ... }:
let inherit (builtins) attrValues;
in
{
  home.packages = attrValues {
    inherit (pkgs) google-chrome;
  };
}
