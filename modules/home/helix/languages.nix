{ config, lib, pkgs, ... }:
let
  inherit (builtins) attrValues readFile;
  vsgFmtWrapperPath = "helix/scripts/vsg_wrapper.nu";
  vsgFmtWrapper = readFile ./vsg_wrapper.nu;
in
{
  xdg.configFile.${vsgFmtWrapperPath} = {
    text = vsgFmtWrapper;
    executable = true;
  };
  programs.helix = {
    extraPackages = attrValues {
      inherit (pkgs)
        nushell
        ;
    };

    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "nixpkgs-fmt";
        }
        {
          name = "go";
          formatter.command = "gofmt";
        }
        {
          name = "python";
          auto-format = true;
          language-servers = [ "pyright" "ruff" ];
          formatter = {
            command = "black";
            args = [ "-" "--quiet" ];
          };
        }
        {
          name = "vhdl";
          formatter = {
            command = "${config.xdg.configHome}/${vsgFmtWrapperPath}";
            args = [ ];
          };
        }
      ];
    };
  };
}
