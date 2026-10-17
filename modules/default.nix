{ ... }:
{
  imports = [
    ./flatpak.nix
    ./musnix.nix
    ./tailscale.nix
    ./pipewire.nix
    ./user.nix
    ./gitlab-runner.nix
    ./logseq-sync.nix
    ./hyprland.nix
    ./microvm.nix
  ];
}
