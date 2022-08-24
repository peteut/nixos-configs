{ nixpkgs, pkgs, ... }: {
  nix.settings.trusted-public-keys = [ (builtins.readFile ../nix-pub.pem) ];
  nix.registry.nixpkgs.flake = nixpkgs;

  nix.package = pkgs.nixFlakes;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
