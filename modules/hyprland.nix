{ config, lib, pkgs, ... }:
let
  cfg = config.modules.hyprland;
  inherit (builtins) attrValues;
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
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = attrValues {
        inherit (pkgs) xdg-desktop-portal-gtk;
      };
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
