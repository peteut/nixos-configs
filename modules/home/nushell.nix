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
          $env.SSH_AUTH_SOCK = $"($env.XDG_RUNTIME_DIR)/ssh-agent"
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
    };
    services.ssh-agent = {
      enable = true;
    };
  };
}
