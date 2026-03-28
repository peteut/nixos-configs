{ lib, config, ... }:
let
  cfg = config.modules.flatpak;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.modules.flatpak = { enable = mkEnableOption "flatpak"; };

  config = mkIf cfg.enable {
    services.flatpak.enable = true;
  };
}
