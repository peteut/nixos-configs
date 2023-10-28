# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, nixos-hardware, modulesPath, ... }:
let
  routerIP = "192.168.1.1";
  myIP = "192.168.1.2";
  magicDNS = "100.100.100.100";
  tailscaleNet = "tail1968e.ts.net";
in
{
  imports = [
    ../../modules/common.nix
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.raspberry-pi-4
    (modulesPath + "/profiles/minimal.nix")
    (modulesPath + "/profiles/headless.nix")
    (modulesPath + "/config/stevenblack.nix")
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_rpi4;
    # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
    loader.grub.enable = false;
    # Enables the generation of /boot/extlinux/extlinux.conf
    loader.generic-extlinux-compatible.enable = true;
  };

  # hardware.raspberry-pi."4".fkms-3d.enable = true;

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  networking = {
    stevenblack = {
      enable = true;
      block = [ "fakenews" "gambling" "porn" ];
    };
    dhcpcd.enable = false;
    interfaces.eth0 = {
      ipv4.addresses = [{
        address = myIP;
        prefixLength = 24;
      }];
    };
    defaultGateway = routerIP;
    nameservers = [ "127.0.0.1" ];
  };

  users.users.alain = {
    isNormalUser = true;
    password = "";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };
  users.users."alain".openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIDUH/SxeU7lXwAWnxaS1HaXTeO8wbplSfjDvskvaX/j alain@x1"
  ];

  environment.systemPackages = [ pkgs.curl pkgs.vim pkgs.tailscale ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.dnsmasq = {
    enable = true;
    settings = {
      server = [ "${routerIP}" "/${tailscaleNet}/${magicDNS}" ];
      dhcp-range = [ "192.168.1.100,192.168.1.199,255.255.255.0,12h" ];
      bogus-priv = true;
      filterwin2k = true;
      no-poll = true;
      dhcp-option = [ "option:router,${routerIP}" ];
      local = [ "/lan/" ];
      domain = [ "lan" ];
      expand-hosts = true;
    };
  };

  services.tailscale = { enable = true; };

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ 53 67 68 config.services.tailscale.port 8080 ];
    allowedTCPPorts = [ 8080 ];
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
