{ nixpkgs, pkgs, ... }: {
  boot.tmp = {
    useTmpfs = true;
  };
  # Set your time zone.
  time.timeZone = "Europe/Zurich";
  nix = {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings.trusted-public-keys = [ (builtins.readFile ../nix-pub.pem) ];
    registry.nixpkgs.flake = nixpkgs;

    package = pkgs.nixFlakes;
    settings.experimental-features = [ "nix-command" "flakes" "repl-flake" ];
  };
}
