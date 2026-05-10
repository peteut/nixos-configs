{ osConfig
, inputs
, ...
}:
let
  cfg = osConfig.services.flatpak;
in
{
  imports = [ inputs.flatpak.homeManagerModules.nix-flatpak ];
  services.flatpak = {
    enable = cfg.enable;
    packages = [
      "com.tdameritrade.ThinkOrSwim"
    ];
  };
}
