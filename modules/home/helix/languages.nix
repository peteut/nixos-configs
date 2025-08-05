{ config, lib, pkgs, ... }:
let
  inherit (builtins) attrValues readFile;
  inherit (lib) getExe getExe';
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
        nixd
        nil
        marksman
        gopls
        go# for gofmt
        golangci-lint-langserver
        ruff
        pyright
        vhdl-ls
        nushell
        ;
    };

    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = getExe pkgs.nixpkgs-fmt;
        }
        {
          name = "go";
          formatter.command = getExe' pkgs.go "gofmt";
        }
        {
          name = "python";
          auto-format = true;
          language-servers = [ "pyright" "ruff" ];
          formatter = {
            command = getExe pkgs.black;
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
