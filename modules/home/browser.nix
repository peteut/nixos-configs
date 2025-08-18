{ lib, osConfig, pkgs, ... }:

let
  cfg = osConfig.modules.hyprland;
  inherit (lib) mkIf;
  inherit (builtins) attrValues;
in
{
  config = mkIf cfg.enable {
    home.packages = attrValues {
      inherit (pkgs) google-chrome;
    };
  };
}
