{ lib, config, pkgs, ... }:
let
  cfg = config.modules.gitlabRunner;
  inherit (lib) mkEnableOption mkIf;

  ciUser = "gitlab-ci";
  ciUid = 1500;
  name = "gitlab-runner";
in
{
  options.modules.gitlabRunner = {
    enable = mkEnableOption "GitLab runner in rootless podman under a dedicated user";
  };

  config = mkIf cfg.enable {
    assertions = [{
      # home-manager is imported and configured by modules.user.
      assertion = config.modules.user.enable;
      message = "modules.gitlabRunner requires modules.user.enable (home-manager).";
    }];

    users.users."${ciUser}" = {
      isNormalUser = true;
      group = "${ciUser}";
      description = "${ciUser}";
      uid = ciUid;
      linger = true; # Ensures containers keep running even when user is not logged in
      shell = pkgs.bash;
    };

    users.groups."${ciUser}" = {
      name = "${ciUser}";
    };

    # Rootless podman needs the system part: newuidmap/newgidmap wrappers,
    # /etc/containers policy, and the podman.socket user unit used below.
    virtualisation.podman.enable = true;

    systemd.user.sockets.podman = {
      wantedBy = [ "sockets.target" ];
      unitConfig.ConditionUser = "${ciUser}";
    };

    # Minimal CI user: no desktop/home modules, no user packages.
    home-manager.users."${ciUser}" = {
      home = {
        username = "${ciUser}";
        stateVersion = "24.05";
        homeDirectory = "/home/${ciUser}";
      };

      services.podman = {
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
}
