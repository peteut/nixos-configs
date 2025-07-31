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
  config = mkIf cfg.enable {
    programs.texlive = {
      enable = true;
      inherit extraPackages;
    };
  };
}
