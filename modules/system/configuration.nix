{ inputs, pkgs, ... }:
let
  inherit (builtins) readFile;
in
{
  boot.tmp = {
    useTmpfs = true;
  };
  # https://blog.cloudlinux.com/cve-2026-31431-copy-fail-mitigation-and-patches
  boot.kernelParams = [ "initcall_blacklist=algif_aead_init" ];
  # Set your time zone.
  time.timeZone = "Europe/Zurich";
  # Select internationalisation properties.
  console = {
    font = "Lat2-Terminus16";
    keyMap = "sg";
  };
  # Weekly GC via `nh clean all` instead of nix.gc: it also prunes per-user
  # profiles (home-manager generations), and always keeps a few generations
  # for rollback on hosts that weren't rebuilt for a while.
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep-since 7d --keep 3";
    };
  };

  nix = {
    settings.auto-optimise-store = true;
    settings = {
      trusted-public-keys = [ (readFile ./../../nix-pub.pem) ];
      trusted-users = [ "root" "alain" ];
    };
    registry.nixpkgs.flake = inputs.nixpkgs;
    package = pkgs.nixVersions.stable;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
