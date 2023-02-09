{ stdenv, meson, fetchFromGitHub, gcc-arm-embedded }:
let
  pname = "picolibc";
  version = "1.8-1";
  name = "${pname}-${version}";
  sha256 = "XKe8ZD4v5CMMeniCB0iqyGc1mbtndWaP7EYq7gI3pPY";
  src = fetchFromGitHub {
    owner = "picolibc";
    repo = pname;
    rev = version;
  };
in
stdenv.mkDerivation {
  inherit name src;

  nativeBuildInputs = [ meson gcc-arm-embedded ];
}
