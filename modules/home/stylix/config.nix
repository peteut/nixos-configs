{ pkgs, ... }:
let
  fontSize = 7;
in
{
  stylix = {
    enable = true;
    icons = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus";
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
