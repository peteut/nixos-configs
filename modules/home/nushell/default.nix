{ config, pkgsUnstable, ... }:
{
  config = {
    programs.nushell =
      let
        inherit (builtins) readFile;
        init = readFile ./init.nu;
      in
      {
        enable = true;
        settings = {
          show_banner = false;
        };
        extraConfig = ''
          use std/dirs

          ${init}
        '';
        extraEnv = ''
          do --env {
            $env.XDG_RUNTIME_DIR = $"($env.XDG_RUNTIME_DIR? | default $"/run/user/(id -u)")"
          }
        '';
        environmentVariables = config.home.sessionVariables //
          {
            CARAPACE_BRIDGES = "zsh,bash";
          };
      };
    programs = {
      direnv = {
        enable = true;
        enableNushellIntegration = true;
      };
      carapace = {
        enable = true;
        package = pkgsUnstable.carapace;
        enableNushellIntegration = true;
      };
      starship = {
        enableNushellIntegration = true;
      };
    };
    services.ssh-agent = {
      enable = true;
    };
  };
}
