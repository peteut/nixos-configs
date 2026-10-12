{ config, lib, pkgs, inputs, username, ... }:
let
  cfg = config.modules.hyprland;
  inherit (builtins) attrValues;
  inherit (lib) mkIf mkEnableOption;
  # stylix is configured per user (home-manager); reuse its theme for the greeter.
  stylix = config.home-manager.users.${username}.stylix;
  colors = config.home-manager.users.${username}.lib.stylix.colors.withHashtag;
in
{
  imports = [ inputs.noctalia-greeter.nixosModules.default ];

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

    # greetd + Noctalia Greeter, styled like the Noctalia shell (stylix Nord).
    services.displayManager.noctalia-greeter = {
      enable = true;
      settings = {
        user.default = username;
        keyboard.layout = "ch";
        appearance = {
          scheme = "Synced";
          theme_mode = if stylix.polarity == "light" then "light" else "dark";
          font_family = stylix.fonts.sansSerif.name;
          wallpaper = {
            path = stylix.image;
            fill_mode = "crop";
          };
          # Same mapping as the stylix noctalia target.
          palette = with colors; {
            primary = base0D;
            on_primary = base00;
            secondary = base0E;
            on_secondary = base00;
            tertiary = base0C;
            on_tertiary = base00;
            error = base08;
            on_error = base00;
            surface = base00;
            on_surface = base05;
            surface_variant = base01;
            on_surface_variant = base04;
            outline = base03;
            shadow = base00;
            hover = base0C;
            on_hover = base00;
          };
        };
      };
    };
  };
}
