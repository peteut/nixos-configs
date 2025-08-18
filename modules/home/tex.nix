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
    enable = true;
    inherit extraPackages;
  };
}
