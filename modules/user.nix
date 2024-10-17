{ inputs, pkgs, username, host, ... }:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs username host; };
    users.${username} = {
      imports = [ ./home ];
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
    shell = pkgs.zsh;
  };
}
