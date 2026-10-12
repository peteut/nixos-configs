{ osConfig, ... }:
{
  programs.sioyek = {
    enable = osConfig.modules.hyprland.enable;
  };
}
