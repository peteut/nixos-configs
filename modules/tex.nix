{ lib, config, ... }:
let
  cfg = config.modules.tex;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.modules.tex = {
    enable = mkEnableOption "tex";
  };

  config = mkIf cfg.enable {
    # moved to HM
  };
}
