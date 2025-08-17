{ inputs, config, pkgs, pkgsUnstable, lib, username, host, ... }:
let
  cfg = config.modules.user;
  inherit (builtins) listToAttrs;
  inherit (lib) mkEnableOption mkIf mkOption types getName;
  inherit (lib.attrsets) nameValuePair;
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
    programs = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = ''
        Programs configured by home-manager.
      '';
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

  config = mkIf cfg.enable {
    home-manager = {
      sharedModules = [ (import ./home) ];
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
        programs = (listToAttrs
          (map
            (p: nameValuePair (getName p) { enable = true; })
            cfg.programs)) // {
          home-manager.enable = true;
        };
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
