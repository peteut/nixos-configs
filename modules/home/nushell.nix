{ ... }:
{
  config = {
    programs.nushell = {
      enable = true;
      settings = {
        show_banner = false;
      };
    };
    programs.direnv = {
      enable = true;
      enableNushellIntegration = true;
    };
  };
}
