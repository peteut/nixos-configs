{ osConfig, lib, pkgs, pkgsUnstable, ... }:
let
  inherit (lib) mkIf concatMap;
  inherit (builtins) elem attrValues;
  package = osConfig.modules.user.editor;
  getPkg = p: attrValues {
    inherit (p) helix;
  };
  matchingPkgs = concatMap getPkg [ pkgs pkgsUnstable ];
in
{
  config = mkIf
    (elem
      package
      matchingPkgs)
    {
      programs.helix = {
        enable = true;
        inherit package;
      };
      home.sessionVariables = { EDITOR = "hx"; };
    };
}
