{ stdenv, fetchurl }:
let
  pname = "atlc";
  version = "4.6.1";
  name = "${pname}-${version}";
  url = "mirror://sourceforge/atlc/${pname}-${version}.tar.bz2";
  sha256 = "0ad8f9bb2a9c59ed452ffd8fdbad85a53d0c3022e69d479caa4ab9c0a6841321";
  src = fetchurl { inherit url sha256; };
in
stdenv.mkDerivation {
  inherit name src;
}
