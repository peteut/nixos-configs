{ config, pkgsUnstable, ... }:
{
  config = {
    programs.nushell = {
      enable = true;
      settings = {
        show_banner = false;
      };
      extraConfig = ''
        do --env {
          $env.SSH_AUTH_SOCK = $"($env.XDG_RUNTIME_DIR? | default $"/run/user/(id -u)")/ssh-agent"
        }
        use std/dirs

        def ssh-connect [
          domain_name: string,
          ...prog: string,
        ] : {
          (wezterm connect $"SSHMUX:($domain_name)" ...$prog)
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
