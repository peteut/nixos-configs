{ config, ... }:
let
  uwsmPrefix = "uwsm app -- ";
  cmds = {
    lock = "${uwsmPrefix} loginctl lock-session";
    suspend = "${uwsmPrefix} systemctl suspend";
    reboot = "${uwsmPrefix} systemctl reboot";
    powerOff = "${uwsmPrefix} systemctl poweroff";
    logout = "${uwsmPrefix} hyprctl dispatch exit 0";
  };
  entry = l: a: ''{ label: "${l}", action: "${a}" }'';
  powerMenu = ''
    #!/usr/bin/env nu

    let choices = [
      ${(entry " Lock" cmds.lock)}
      ${(entry " Suspend" cmds.suspend)}
      ${(entry " Reboot" cmds.reboot)}
      ${(entry "⏻ Power Off" cmds.powerOff)}
      ${(entry " Logout" cmds.logout)}
    ]
    let menu = $choices | get label | str join "\n"
    let selected = (echo $menu | wofi --dmenu --width 200 --height 300 --prompt "Power" | str trim)
    if $selected != "" {
      let action = ($choices | where label == $selected | get action | first)
      ^sh -c $action
    }
  '';
  powerMenuPath = "waybar/scripts/power-menu.nu";
in
{
  xdg.configFile.${powerMenuPath} = {
    text = powerMenu;
    executable = true;
  };
  programs.waybar.settings.mainBar = {
    position = "bottom";
    layer = "top";
    height = 28;
    margin-top = 0;
    margin-bottom = 0;
    margin-left = 0;
    margin-right = 0;
    modules-left = [
      "hyprland/workspaces"
      "tray"
    ];
    modules-center = [ "clock" ];
    modules-right = [
      "cpu"
      "memory"
      "disk"
      "pulseaudio"
      "network"
      "battery"
      "custom/power"
    ];
    clock = {
      format = "  {:%H:%M}";
      tooltip = "true";
      tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      format-alt = "  {:%d/%m}";
    };
    "hyprland/workspaces" = {
      active-only = false;
      disable-scroll = true;
      format = "{icon}";
      on-click = "activate";
      format-icons = {
        "1" = "I";
        "2" = "II";
        "3" = "III";
        "4" = "IV";
        "5" = "V";
        "6" = "VI";
        "7" = "VII";
        "8" = "VIII";
        "9" = "IX";
        "10" = "X";
        sort-by-number = true;
      };
      persistent-workspaces = {
        "1" = [ ];
        "2" = [ ];
        "3" = [ ];
        "4" = [ ];
        "5" = [ ];
      };
    };
    cpu = {
      format = " {usage}%";
      format-alt = " {avg_frequency} GHz";
      interval = 2;
    };
    memory = {
      format = "󰟜 {}%";
      format-alt = "󰟜 {used} GiB";
      interval = 2;
    };
    disk = {
      format = "󰋊 {percentage_used}%";
      interval = 60;
    };
    network = {
      format-wifi = "  {signalStrength}%";
      format-ethernet = "󰀂";
      tooltip-format = "Connected to {essid} {ifname} via {gwaddr}";
      format-linked = "{ifname} (No IP)";
      format-disconnected = "󰖪";
    };
    tray = {
      icon-size = 20;
      spacing = 8;
    };
    pulseaudio = {
      format = "{icon} {volume}%";
      format-muted = "  {volume}%";
      format-icons = {
        default = [ " " ];
      };
      scroll-step = 2;
      on-click = "pamixer -t";
      on-click-right = "pavucontrol";
    };
    battery = {
      format = "{icon} {capacity}%";
      format-icons = [
        " "
        " "
        " "
        " "
        " "
      ];
      format-charging = " {capacity}%";
      format-full = " {capacity}%";
      format-warning = "{capacity}%";
      interval = 5;
      states = {
        warning = 20;
      };
      format-time = "{H}h{M}m";
      tooltip = true;
      tooltip-format = "{time}";
    };
    "custom/power" = {
      format = "⏻ ";
      on-click = "${config.xdg.configHome}/${powerMenuPath}";
      tooltip = true;
      tooltip-format = "⏻  Click for options";
    };
  };
}
