# Backport of stylix master's `targets.noctalia` (Noctalia v5).
# release-26.05 only ships `targets.noctalia-shell`, which targets v4
# (`programs.noctalia-shell`) and is a silent no-op with v5.
# Drop this file once the stylix input provides `stylix.targets.noctalia`.
{ config, lib, osConfig, ... }:
let
  cfg = osConfig.modules.hyprland;
  inherit (lib) mkIf;
  stylix = config.stylix;
  palette = "stylix";
in
{
  config = mkIf (cfg.enable && stylix.enable) {
    programs.noctalia = {
      settings = {
        theme = {
          source = "custom";
          custom_palette = palette;
          mode = if stylix.polarity == "light" then "light" else "dark";
        };
        shell.font_family = stylix.fonts.sansSerif.name;
        wallpaper.default.path = stylix.image;
        dock.background_opacity = stylix.opacity.desktop;
        notification.background_opacity = stylix.opacity.popups;
        osd.background_opacity = stylix.opacity.popups;
      };

      customPalettes.${palette}.dark = with config.lib.stylix.colors.withHashtag; {
        mPrimary = base0D;
        mOnPrimary = base00;
        mSecondary = base0E;
        mOnSecondary = base00;
        mTertiary = base0C;
        mOnTertiary = base00;
        mError = base08;
        mOnError = base00;
        mSurface = base00;
        mOnSurface = base05;
        mHover = base0C;
        mOnHover = base00;
        mSurfaceVariant = base01;
        mOnSurfaceVariant = base04;
        mOutline = base03;
        mShadow = base00;

        terminal = {
          foreground = base05;
          background = base00;
          cursor = base05;
          cursorText = base00;
          selectionFg = base05;
          selectionBg = base02;
          normal = {
            black = base00;
            red = base08;
            green = base0B;
            yellow = base0A;
            blue = base0D;
            magenta = base0E;
            cyan = base0C;
            white = base05;
          };
          bright = {
            black = base03;
            red = base08;
            green = base0B;
            yellow = base0A;
            blue = base0D;
            magenta = base0E;
            cyan = base0C;
            white = base07;
          };
        };
      };
    };
  };
}
