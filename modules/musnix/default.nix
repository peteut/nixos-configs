{ lib, config, inputs, ... }:
let
  cfg = config.modules.musnix;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.modules.musnix = { enable = mkEnableOption "musnix"; };

  imports = [
    inputs.musnix.nixosModules.musnix
  ];
  config = mkIf cfg.enable {
    musnix.enable = true;
  };
}
