{ pkgs, ... }:
let
  inherit (builtins) attrValues;
in
{
  home.packages = attrValues {
    inherit (pkgs) wlogout;
  };

  programs.wlogout = {
    enable = true;
    # refer to https://github.com/ArtsyMacaw/wlogout/blob/master/layout
    layout = [
      {
        label = "logout";
        action = "hyprctl dispatch exit 0";
        text = "Exit";
        keybind = "exit";
      }
      {
        label = "shutdown";
        action = "systemctl poweroff";
        text = "Shutdown";
        keybind = "s";
      }
      {
        label = "suspend";
        action = "systemctl suspend";
        text = "Suspend";
        keybind = "u";
      }
      {
        label = "reboot";
        action = "systemctl reboot";
        text = "Reboot";
        keybind = "r";
      }
    ];
  };
}
