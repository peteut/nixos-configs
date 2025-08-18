{ lib, osConfig, ... }:
let
  cfg = osConfig.modules.hyprland;
  inherit (lib) mkIf;
in
{
  programs.waybar = mkIf cfg.enable {
    enable = true;
    systemd.enable = true;
  };
}
