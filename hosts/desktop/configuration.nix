{ config, pkgs, ... }: {
  imports = [
    ../../modules
    ../../modules/wsl
  ];

  config = {
    modules = {
      nvim.enable = true;
      wsl.enable = true;
    };

    boot.kernelModules = [ "tun" ];

    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    services.tailscale = {
      enable = true;
      extraUpFlags = [ "--ssh" ];
    };
    networking.firewall = {
      enable = true;
      checkReversePath = "loose";
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
      # Refer to https://github.com/microsoft/WSL/issues/6655
      # package = pkgs.iptables;
    };

    users.users.alain = {
      isNormalUser = true;
      password = "";
      extraGroups = [ "wheel" "users" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIDUH/SxeU7lXwAWnxaS1HaXTeO8wbplSfjDvskvaX/j alain@x1"
      ];
    };

    environment.systemPackages = builtins.attrValues
      {
        inherit (pkgs)
          direnv
          git
          unzip;
      };
  };
}
