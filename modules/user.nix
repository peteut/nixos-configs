{ inputs, config, pkgs, pkgsUnstable, lib, username, host, ... }:
let
  cfg = config.modules.user;
  inherit (lib) mkEnableOption mkIf mkOption types;
  inherit (lib.options) mkPackageOption;
  ciUser = "gitlab-ci";
  ciUid = 1500;
in
{
  options.modules.user = {
    enable = mkEnableOption "user";
    ciRunner = mkEnableOption "ciRunner";
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

      users.users."${ciUser}" = mkIf cfg.ciRunner {
        isNormalUser = true;
        group = "${ciUser}";
        description = "${ciUser}";
        uid = ciUid;
        linger = true; # Ensures containers keep running even when user is not logged in
        shell = pkgs.bash;
      };

      users.groups."${ciUser}" = mkIf cfg.ciRunner {
        name = "${ciUser}";
      };

      # Rootless podman needs the system part: newuidmap/newgidmap wrappers,
      # /etc/containers policy, and the podman.socket user unit used below.
      virtualisation.podman.enable = mkIf cfg.ciRunner true;

      systemd.user.sockets.podman = mkIf cfg.ciRunner {
        wantedBy = [ "sockets.target" ];
        unitConfig.ConditionUser = "${ciUser}";
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

        # Minimal CI user: no desktop/home modules, no user packages.
        users."${ciUser}" = mkIf cfg.ciRunner {
          home = {
            username = "${ciUser}";
            stateVersion = "24.05";
            homeDirectory = "/home/${ciUser}";
          };

          services.podman =
            let
              name = "gitlab-runner";
            in
            {
              enable = true;
              settings = {
                registries.search = [ "docker.io" "ghcr.io" ];
              };

              containers = {
                "${name}" = {
                  autoStart = true;
                  image = "docker.io/gitlab/${name}:v19.4.1"; # pin, bump deliberately
                  volumes = [
                    "/run/user/${toString ciUid}/podman/podman.sock:/var/run/docker.sock"
                    "/home/${ciUser}/${name}:/etc/${name}"
                  ];
                };
              };
            };
        };
      };
    };
}
