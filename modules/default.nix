{ ... }:
{
  imports = [
    ./flatpak.nix
    ./musnix.nix
    ./tailscale.nix
    ./pipewire.nix
    ./user.nix
    ./gitlab-runner.nix
    ./hyprland.nix
    ./microvm.nix
  ];
}
