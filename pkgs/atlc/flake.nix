{
  description = "atlc";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      pname = "atlc";
      version = "4.6.1";
      url = "mirror://sourceforge/atlc/${pname}-${version}.tar.bz2";
      sha256 = "0ad8f9bb2a9c59ed452ffd8fdbad85a53d0c3022e69d479caa4ab9c0a6841321";
      src = (pkgs.fetchurl {
        inherit url sha256;
      });
    in
    {
      defaultPackage.${system} = pkgs.stdenv.mkDerivation {
        name = "${pname}-${version}";
        inherit pname src;
      };
    };
}
