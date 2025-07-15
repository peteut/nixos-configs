{ inputs, pkgs, ... }:
let fontSize = 8;
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

      fonts.sizes = {
        applications = fontSize;
        desktop = fontSize;
        popups = fontSize;
        terminal = fontSize;
      };
    };
  };
}
