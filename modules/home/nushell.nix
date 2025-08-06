{ osConfig, lib, pkgsUnstable, ... }:
let
  inherit (lib) mkIf hasAttrByPath;
in
{
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
}
