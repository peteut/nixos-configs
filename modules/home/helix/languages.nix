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
        marksman
        markdown-oxide
        typos-lsp
        ;
    };
    languages = {
      language-server = {
        typos = {
          command = "typos-lsp";
          args = [ ];
        };
      };
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "nixpkgs-fmt";
          language-servers = [ "nil" "nixd" "typos" ];
        }
        {
          name = "go";
          formatter.command = "gofmt";
          language-servers = [ "gopls" "golangci-lint-lsp" "typos" ];
        }
        {
          name = "python";
          auto-format = true;
          language-servers = [ "pyright" "ruff" "typos" ];
          formatter = {
            command = "black";
            args = [ "-" "--quiet" ];
          };
        }
        {
          name = "vhdl";
          language-servers = [ "vhdl_ls" "typos" ];
          formatter = {
            command = "${config.xdg.configHome}/${vsgFmtWrapperPath}";
            args = [ ];
          };
        }
        {
          name = "markdown";
          language-servers = [ "marksman" "markdown-oxide" "typos" ];
        }
      ];
    };
  };
}
