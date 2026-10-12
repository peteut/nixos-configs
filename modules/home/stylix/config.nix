{ lib, osConfig, pkgs, ... }:
let
  cfg = osConfig.modules.hyprland;
  inherit (lib) mkIf;
  fontSize = 7;
in
{
  stylix = mkIf cfg.enable {
    enable = true;
    targets."helix".enable = false;
    # v4-only target, superseded by ./noctalia.nix
    targets.noctalia-shell.enable = false;
    # Noctalia draws the wallpaper; don't run hyprpaper alongside it.
    targets.hyprland.hyprpaper.enable = false;
    icons = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
    };
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
    image = ./assets/nord-nixos.png;

    cursor = {
      package = pkgs.rose-pine-hyprcursor;
      name = "rose-pine-hyprcursor";
      size = 16;
    };

    fonts = {
      sansSerif = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sizes = {
        applications = fontSize;
        desktop = fontSize;
        popups = fontSize;
        terminal = fontSize;
      };
    };
  };
}
