{ osConfig
, inputs
, ...
}:
let
  cfg = osConfig.services.flatpak;
in
{
  imports = [ inputs.flatpaks.homeModules.default ];
  services.flatpak = {
    enable = cfg.enable;
  };
}
