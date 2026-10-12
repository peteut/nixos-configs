{ pkgs, ... }: {
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
    # Expose the Windows host's NVIDIA driver (libcuda) via /run/opengl-driver.
    wsl.useWindowsDriver = true;
    environment.systemPackages = [
      (pkgs.llama-cpp.override { cudaSupport = true; })
    ];
  };
}
