{ lib, config, inputs, username, ... }:
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
      usbip.enable = true;
      wslConf = {
        automount.root = "/mnt";
        interop = {
          enabled = false;
          appendWindowsPath = false;
        };
        network = {
          generateResolvConf = false;
        };
      };
      defaultUser = username;
      startMenuLaunchers = true;
    };
  };
}
