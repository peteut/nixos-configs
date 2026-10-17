{ inputs, config, pkgs, pkgsUnstable, lib, username, host, ... }:
let
  cfg = config.modules.user;
  inherit (lib) mkEnableOption mkIf mkOption types;
  inherit (lib.options) mkPackageOption;
in
{
  options.modules.user = {
    enable = mkEnableOption "user";
    shell = mkPackageOption pkgs "shell" {
      default = "nushell";
    };
    editor = mkPackageOption pkgsUnstable "editor" {
      default = "helix";
    };
    packages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = ''
        User packages.
      '';
    };
  };
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  config = mkIf cfg.enable
    {
      users.users.${username} = {
        isNormalUser = true;
        description = "${username}";
        uid = 1000;
        extraGroups = [ "networkmanager" "wheel" "audio" "dialout" "kvm" ];
        shell = cfg.shell;
      };

      home-manager = {
        useUserPackages = true;
        useGlobalPkgs = true;
        backupFileExtension = "bak";
        verbose = true;
        extraSpecialArgs = { inherit inputs username host pkgsUnstable; };
        users.${username} = {
          imports = [
            inputs.stylix.homeModules.stylix
            ./home
          ];
          home = {
            username = "${username}";
            stateVersion = "24.05";
            homeDirectory = "/home/${username}";
            packages = cfg.packages;
          };
          programs.home-manager.enable = true;
        };
      };
    };
}
