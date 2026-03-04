{ microvm
, lib
, pkgs
, hostName ? "microVM"
, shares ? [ ]
, vcpu ? 8
, mem ? 4096
, extraPkgs ? [ ]
, user
, uid ? 1000
, authorizedKeys ? [ ]
}:
let
  hypervisor = "cloud-hypervisor";
  # Hash the hostname to get a deterministic seed
  hash = builtins.hashString "sha256" hostName;
  # Extract bytes from the hash string (each 2 hex chars = 1 byte)
  byte = offset: builtins.substring offset 2 hash;
  mac = lib.concatStringsSep ":" [
    # locally administered, unicast: set bit 1 of first octet, clear bit 0
    "02"
    (byte 2)
    (byte 4)
    (byte 6)
    (byte 8)
    (byte 10)
  ];

  # 192.168.83.x, x in range 2-254
  # Take a byte from the hash and map it into 2-254
  lastOctet = 2 + (lib.mod (lib.fromHexString (builtins.substring 12 2 hash)) 253);
  ip = "192.168.83.${toString lastOctet}";
  bridgeIp = "192.168.83.1";

  cfg = { config, pkgs, ... }: {
    imports = [
      microvm.nixosModules.microvm
    ];
    networking = {
      inherit hostName;
    };
    system.stateVersion = "25.11";

    users.users.root.password = "";
    services.getty.helpLine = ''
      Log in as "root" with an empty password.
    '';

    users.users.${user} = {
      inherit uid;
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = authorizedKeys;
    };

    services.openssh = {
      enable = true;
      settings.PermitRootLogin = "no";
    };

    networking = {
      useNetworkd = true;
      tempAddresses = "disabled";
    };
    systemd.network = {
      enable = true;
      networks."20-eth" = {
        matchConfig.MACAddress = mac;
        addresses = [{ Address = "${ip}/24"; }];
        routes = [{ Gateway = bridgeIp; }];
        networkConfig.DNS = bridgeIp; # or whatever DNS you use
      };
    };
    environment.systemPackages = (builtins.attrValues
      {
        inherit (pkgs)
          git
          htop
          iproute2
          iputils
          claude-code
          ;
      }) ++ extraPkgs;

    microvm = {
      shares = [{
        tag = "ro-store";
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
        proto = "virtiofs";
      }] ++ shares;
      writableStoreOverlay = "/nix/.rw-store";
      volumes = [{
        image = "nix-store-overlay.img";
        mountPoint = config.microvm.writableStoreOverlay;
        size = 2048;
      }];
      interfaces = [
        {
          type = "tap";
          id = "${hostName}-tap";
          inherit mac;
        }
      ];

      inherit hypervisor vcpu mem;
      vsock.cid = 3 + (lib.mod (lib.fromHexString (byte 14)) 1000);
    };
  };
  nixos = pkgs.nixos
    cfg;
in
nixos.config.microvm.declaredRunner
