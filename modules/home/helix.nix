{ pkgs, ... }:
let
  inherit (builtins) attrValues;
in
{
  programs.helix = {
    enable = true;
    extraPackages = attrValues {
      inherit (pkgs)
        marksman
        nixd
        ;
    };
    settings = {
      keys = {
        normal = {
          up = "no_op";
          down = "no_op";
          left = "no_op";
          right = "no_op";
          pageup = "no_op";
          pagedown = "no_op";
          home = "no_op";
          end = "no_op";
        };
        normal.g = {
          G = "goto_file_end";
          g = "goto_file_start";
        };
        insert = {
          up = "no_op";
          down = "no_op";
          left = "no_op";
          right = "no_op";
          pageup = "no_op";
          pagedown = "no_op";
          home = "no_op";
          end = "no_op";
        };
      };
    };
  };
}
