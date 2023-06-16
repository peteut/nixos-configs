{ config, nixos-wsl, pkgs, ... }:
let
in {
  imports = [
    ../../modules/common.nix
    ../../modules/nvim.nix
    nixos-wsl.nixosModules.wsl
  ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  time.timeZone = "Europe/Zurich";

  services.tailscale = { enable = true; };
  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
    # Refer to https://github.com/microsoft/WSL/issues/6655
    # package = pkgs.iptables;
  };

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = "alain";
    startMenuLaunchers = true;
  };

  users.users.alain = {
    isNormalUser = true;
    password = "";
    extraGroups = [ "wheel" "users" ];
  };

  environment.systemPackages = builtins.attrValues
    {
      inherit (pkgs)
        direnv
        git
        unzip;
    };

  system.stateVersion = "22.05";
}
