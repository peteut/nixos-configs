{
  description = "My packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      inherit (flake-utils.lib) eachSystem;
      inherit (flake-utils.lib.system) x86_64-linux aarch64-linux;
    in
    eachSystem [ x86_64-linux aarch64-linux ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
        packages = packages.${system};
      in
      {
        packages = {
          atlc = pkgs.callPackage ./atlc/default.nix { };
          pianoteq = pkgs.callPackage ./pianoteq6/default.nix { };
        };
      });
}

