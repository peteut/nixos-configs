{ lib, pkgs, config, ... }:
let
  cfg = config.modules.hyprland;
  inherit (builtins) attrValues;
  inherit (lib) mkIf mkEnableOption;
in
{
  options.modules.hyprland = {
    enable = mkEnableOption "hyprland";
  };
  config = mkIf cfg.enable {
    programs.hyprland.enable = true;
  };
}
