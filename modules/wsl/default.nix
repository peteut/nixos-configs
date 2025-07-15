{ lib, config, inputs, ... }:
let
  cfg = config.modules.wsl;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.modules.wsl = { enable = mkEnableOption "wsl"; };

  imports = [
    inputs.nixos-wsl.nixosModules.wsl
  ];
  config = mkIf cfg.enable {
    wsl = {
      enable = true;
      wslConf.automount.root = "/mnt";
      defaultUser = "alain";
      startMenuLaunchers = true;
    };
  };
}
