{ lib, osConfig, ... }:
let
  cfg = osConfig.modules.tex;
  inherit (lib) mkIf;
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
  programs.texlive = mkIf cfg.enable {
    enable = true;
    inherit extraPackages;
  };
}
