{ ... }:
let
  extraPackages = tpkgs: {
    inherit (tpkgs)
      scheme-tetex
      koma-script
      amsmath
      latexmk
      moderncv;
  };
in
{
  programs.texlive = {
    enable = false;
    inherit extraPackages;
  };
}
