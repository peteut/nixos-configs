{ lib, modules-config, ... }:
let
  cfg = modules-config.hyprland;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;
    };
  };
}
