{ ... }:
{
  imports = [
    ./browser.nix
    ./zsh.nix
    ./btop.nix
    ./git.nix
    ./lazygit.nix
    ./packages
    ./nushell.nix
    ./wezterm.nix
    ./hyprland
    ./waybar
    ./dunst.nix
    ./wofi.nix
    ./wlogout.nix
  ];
}
