{ inputs, pkgs, ... }:
let
  fontSize = 7;
in
{
  imports = [ inputs.stylix.nixosModules.stylix ];

  config = {
    stylix = {
      enable = true;
      polarity = "dark";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
      image = ./assets/nord-nixos.png;

      cursor = {
        package = pkgs.material-cursors;
        name = "pointer";
        size = 24;
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
  };
}
