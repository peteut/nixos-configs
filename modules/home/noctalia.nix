{ lib, osConfig, inputs, ... }:
let
  cfg = osConfig.modules.hyprland;
  inherit (lib) mkIf;
in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];
  programs.noctalia-shell = mkIf cfg.enable
    {
      enable = true;
      settings = {
        bar = {
          density = "compact";
          position = "bottom";
        };
        location = {
          monthBeforeDay = false;
          name = "Bern, Switzerland";
        };
      };
      systemd.enable = true;
    };
}
