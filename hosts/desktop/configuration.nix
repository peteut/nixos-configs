{ ... }: {
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
  };
}
