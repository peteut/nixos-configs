{ lib, osConfig, pkgs, ... }:
let
  cfg = osConfig.modules.hyprland;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      systemd.enable = true;
    };
  };
}
