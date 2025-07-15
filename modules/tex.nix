{ lib, config, pkgs, username, ... }:
let
  cfg = config.modules.tex;
  inherit (lib) mkEnableOption mkIf;
  tex = (pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-tetex koma-script amsmath latexmk moderncv;
  });
in
{
  options.modules.tex = {
    enable = mkEnableOption "tex";
  };

  config = mkIf cfg.enable {
    users.users.${username} = {
      packages = [ tex ];
    };
  };
}
