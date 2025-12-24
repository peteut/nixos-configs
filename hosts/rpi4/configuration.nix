# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, modulesPath, inputs, ... }:
let
  routerIP = "192.168.1.1";
  myIP = "192.168.1.2";
  magicDNS = "100.100.100.100";
  tailscaleNet = "tail1968e.ts.net";
  lib = pkgs.lib;
in
{
  imports = [
    ../../modules
    # ../../modules/common.nix
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    (modulesPath + "/profiles/minimal.nix")
    (modulesPath + "/profiles/headless.nix")
    (modulesPath + "/config/stevenblack.nix")
  ];


  config = {
    nixpkgs.overlays = [
      # Workaround: https://github.com/NixOS/nixpkgs/issues/154163
      # modprobe: FATAL: Module sun4i-drm not found in directory
      (final: super: {
        makeModulesClosure = x:
          super.makeModulesClosure (x // { allowMissing = true; });
      })
    ];
    sdImage.compressImage = false;
    boot = {
      kernelPackages = pkgs.linuxPackages_rpi4;
      supportedFilesystems.zfs = lib.mkForce false;
      # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
      loader.grub.enable = false;
      # Enables the generation of /boot/extlinux/extlinux.conf
      loader.generic-extlinux-compatible.enable = true;
    };

    modules = {
      tailscale = {
        enable = true;
        extraUpFlags = [ "--ssh" "--advertise-exit-node" ];
        useRoutingFeatures = "server";
      };
    };

    # hardware.raspberry-pi."4".fkms-3d.enable = true;
    networking = {
      stevenblack = {
        enable = true;
        block = [ "gambling" "porn" ];
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

    environment.systemPackages = builtins.attrValues {
      inherit (pkgs) vim rsync;
    };

    services.dnsmasq = {
      enable = true;
      resolveLocalQueries = true;
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
        enable-tftp = true;
        tftp-root = "/var/lib/tftp";
        tftp-no-fail = true;
      };
    };

    # Open ports in the firewall.
    networking.firewall = {
      enable = true;
      allowedUDPPorts = [ 53 67 68 69 ];
    };
  };
}
