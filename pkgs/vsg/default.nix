{ lib, pkgs }:
let
  inherit (pkgs.python3Packages) buildPythonPackage;
  inherit (pkgs) fetchFromGitHub;
  inherit (builtins) attrValues;
  inherit (lib.licenses) gpl3;
  pname = "vsg";
  version = "3.33.0";
  format = "pyproject";
in
buildPythonPackage {
  inherit pname version format;
  buildInputs = attrValues {
    inherit (pkgs.python3Packages)
      setuptools
      setuptools-git-versioning
      wheel;
  };
  dependencies = attrValues {
    inherit (pkgs.python3Packages) pyyaml;
  };

  src = fetchFromGitHub {
    owner = "jeremiah-c-leary";
    repo = "vhdl-style-guide";
    rev = "${version}";
    sha256 = "sha256-q8JEin3CeF1a5IWg5YAV4iuc+ZS8ZR62LGpG146C0N4=";
  };

  meta = {
    mainProgram = pname;
    description = "VHDL Style Guide";
    changelog = "https://github.com/jeremiah-c-leary/vhdl-style-guide/tree/${version}";
    license = gpl3;
  };
}
