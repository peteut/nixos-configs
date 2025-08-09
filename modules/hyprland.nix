{ config, lib, pkgs, ... }:
let
  cfg = config.modules.hyprland;
  inherit (lib) mkIf mkEnableOption;
  sddm-astronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = "astronaut";
  };
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
      package = pkgs.kdePackages.sddm;
      extraPackages = [ sddm-astronaut ];
      theme = "sddm-astronaut-theme";
      enable = true;
      wayland.enable = true;
    };
    environment.systemPackages = [ sddm-astronaut ];
  };
}
