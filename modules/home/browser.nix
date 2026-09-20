{ lib, osConfig, ... }:

let
  cfg = osConfig.modules.hyprland;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    programs.librewolf.enable = true;
  };
}
