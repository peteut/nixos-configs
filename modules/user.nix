{ inputs, config, pkgs, lib, username, host, ... }:
let
  cfg = config.modules.user;
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.options) mkPackageOption;
in
{
  options.modules.user = {
    enable = mkEnableOption "user";
    shell = mkPackageOption pkgs "shell" {
      default = "nushell";
    };
  };
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  config = mkIf cfg.enable {
    home-manager = {
      sharedModules = [ (import ./home) ];
      useUserPackages = true;
      useGlobalPkgs = true;
      backupFileExtension = "bak";
      verbose = true;
      extraSpecialArgs = { inherit inputs username host; };
      users.${username} = {
        imports = [
          inputs.stylix.homeModules.stylix
          ./home
        ];
        home = {
          username = "${username}";
          stateVersion = "24.05";
          homeDirectory = "/home/${username}";
        };
        programs.home-manager.enable = true;
      };
    };

    users.users.${username} = {
      isNormalUser = true;
      description = "${username}";
      extraGroups = [ "networkmanager" "wheel" "audio" "dialout" ];
      shell = cfg.shell;
    };
  };
}
