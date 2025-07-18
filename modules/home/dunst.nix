{ pkgs, ... }:
{
  services.dunst = {
    package = pkgs.dunst;
    enable = true;
    settings = {
      global = {
        origin = "top-left";
        timeout = 2;
      };
    };
  };
}
