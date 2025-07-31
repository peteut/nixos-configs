{ osConfig, lib, ... }:
let
  inherit (lib) mkIf hasAttrByPath;
in
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
      environmentVariables = mkIf (hasAttrByPath [ "home" "sessionVariables" "XDG_RUNTIME_DIR" ] osConfig) {
        inherit (osConfig.home.sessionVariables)
          XDG_RUNTIME_DIR
          ;
      };
    };
    programs = {
      direnv = {
        enable = true;
        enableNushellIntegration = true;
      };
      carapace = {
        enable = true;
        enableNushellIntegration = true;
      };
    };
    services.ssh-agent = {
      enable = true;
    };
  };
}
