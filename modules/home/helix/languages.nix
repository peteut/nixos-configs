{ lib, pkgs, ... }:
let
  inherit (builtins) attrValues;
  inherit (lib) getExe getExe';
in
{
  programs.helix = {
    extraPackages = attrValues {
      inherit (pkgs)
        marksman
        gopls
        go# for gofmt
        ;
    };

    languages = {
      language = [
        {
          name = "nix";
          file-types = [ "nix" ];
          auto-format = true;
        }
        {
          name = "go";
          roots = [ "go.mod" ];
          formatter.command = getExe' pkgs.go "gofmt";
          comment-token = "//";
          language-servers = [ "gopls" "golangci-lint-lsp" ];
        }
        {
          name = "python";
          roots = [ "pyproject.toml" ];
          comment-token = "#";
          language-servers = [ "pyright" "ruff" ];
          formatter = {
            command = getExe pkgs.black;
            args = [ "-" "--quiet" ];
          };
        }
      ];
      language-server = {
        nixd.command = getExe pkgs.nixd;
        golang-lint-lsp = {
          command = getExe pkgs.golangci-lint-langserver;
          args = [ "run" "--out-format" "json" ];
        };
        pyright = {
          command = getExe' pkgs.pyright "pyright-langserver";
          args = [ "--stdio" ];
        };
        ruff = {
          command = getExe pkgs.ruff;
        };
      };
    };
  };
}
