{ lib, config, ... }:
let
  cfg = config.modules.hyprland;
  inherit (lib) mkIf mkEnableOption;
in
{
  options.modules.hyprland = {
    enable = mkEnableOption "hyprland";
  };
  config = mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
  };
}

