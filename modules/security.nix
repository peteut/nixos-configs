{ config, lib, ... }:
let
  cfg = config.modules.hyprland;
  inherit (lib) mkIf;
in
{
  # services.hypridle.enable = true;
  config = mkIf cfg.enable {
    security.pam.services.hyprlock = { };
  };
}
