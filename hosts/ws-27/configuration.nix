{ ... }:
let
  nameservers = [ "10.255.255.254" ];
in
{
  imports = [
    ../../modules
    ../../modules/wsl
  ];

  config = {
    modules = {
      wsl.enable = true;
      tailscale = {
        enable = true;
      };
      user = {
        enable = true;
        ciRunner = true;
      };
    };
    boot.kernelModules = [ "tun" ];

    networking =
      {
        inherit nameservers;
        search = [ "spacetek.local" ];
      };

    fileSystems."/mnt/wsl/xilinx" = {
      device = "/home/alain/Xilinx";
      fsType = "none";
      options = [ "bind" "ro" ];
    };
  };
}

