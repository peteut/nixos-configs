{ config, nixos-wsl, ... }:
let
in {
  imports = [
    ../../modules/common.nix
    ../../modules/nvim.nix
    nixos-wsl.nixosModules.wsl
  ];

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
    permitRootLogin = "no";
  };

  time.timeZone = "Europe/Zurich";

  services.tailscale = { enable = true; };
  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = "alain";
    startMenuLaunchers = true;
  };

  system.stateVersion = "22.05";
}
