{ config, lib, pkgs, ... }:
let
  inherit (builtins) attrValues;
  inherit (lib) getExe getExe';
  vsgFmtWrapperPath = "helix/scripts/vsg_wrapper.nu";
  vsgFmtWrapper = ''
    #!/usr/bin/env -S nu --stdin

    def main [] {
      let tmpFile = (mktemp -t --suffix .vhd)
      $in | save -f $tmpFile
      mut cmd = ["vsg" "-of" "syntastic"]
      if $env.VSG_CONFIG? != null and ($env.VSG_CONFIG | path exists) {
        $cmd = $cmd | append ["-c" $"($env.VSG_CONFIG | path expand)"]
      }
      $cmd = $cmd | append ["--fix" $tmpFile]
      run-external ...$cmd | ignore
      open --raw $tmpFile | print
      rm $tmpFile
    }
  '';
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
          name = "go";
          formatter.command = getExe' pkgs.go "gofmt";
        }
        {
          name = "python";
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
