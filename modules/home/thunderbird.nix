{ lib, osConfig, ... }:
let
  cfg = osConfig.modules.hyprland;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    programs.thunderbird = {
      enable = true;
      languagePacks = [
        "en-GB"
        "de_CH"
      ];
      policies = {
        DisableTelemetry = true;
      };
    };
  };
}
