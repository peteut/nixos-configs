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
        # Home-manager package; useGlobalPkgs keeps the sm_61 CUDA target.
        packages = [
          (pkgs.llama-cpp.override { cudaSupport = true; })
        ];
      };
    };
    boot.kernelModules = [ "tun" ];
    # Expose the Windows host's NVIDIA driver (libcuda) via /run/opengl-driver.
    wsl.useWindowsDriver = true;
  };
}
