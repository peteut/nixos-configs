{ lib, osConfig, ... }:
let
  cfg = osConfig.modules.hyprland;
  inherit (lib) mkIf;
in
{
  programs.wofi = mkIf cfg.enable {
    enable = true;
    style = ''
      * {
        font-family: monspace;
       }
    '';
  };
}
