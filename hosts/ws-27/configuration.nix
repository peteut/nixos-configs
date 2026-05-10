{ ... }:
# let
#   nameservers = [ "10.10.10.10" ];
# in
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
      };
      hyprland.enable = true;
    };
    boot.kernelModules = [ "tun" ];
    # wsl.wslConf = {
    #   network.hostname = "nixos-ws-27";
    # };
    # networking = {
    #   inherit nameservers;
    # };
  };
}

