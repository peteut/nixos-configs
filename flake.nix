{
  description = "My deploy-rs config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pre-commit-hooks-nix.follows = "pre-commit-hooks";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix/release-25.05";
    };
  };

  outputs =
    { self
    , deploy-rs
    , flake-utils
    , nixpkgs
    , nixpkgs-unstable
    , pre-commit-hooks
    , ...
    }@inputs:
    let
      inherit (flake-utils.lib) eachSystem;
      inherit (flake-utils.lib.system) x86_64-linux aarch64-linux;

      username = "alain";

      mkSystem = hostName: system: modules:
        let
          inherit (builtins) elem;
          inherit (nixpkgs.lib) getName;
          pkgs = import nixpkgs {
            inherit system;
            config = {
              allowUnfreePredicate = pkg:
                elem (getName pkg) [
                  "google-chrome"
                  "slack"
                  "pianoteq-stage"
                ];
            };
          };
        in
        nixpkgs.lib.nixosSystem {
          inherit system pkgs;
          modules = [
            ./modules/system/configuration.nix
            { networking.hostName = hostName; }
          ] ++ modules;
          specialArgs = {
            inherit self inputs username;
            pkgsUnstable = nixpkgs-unstable.legacyPackages.${system};
          };
        };

    in
    eachSystem [ x86_64-linux aarch64-linux ]
      (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (builtins) attrValues mapAttrs;
      in
      {
        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run
            {
              src = ./.;
              hooks = {
                nixpkgs-fmt.enable = true;
                nix-linter.enable = false;
                stylua.enable = true;
              };
            } // (mapAttrs
            (_: deployLib: deployLib.deployChecks self.deploy)
            deploy-rs.lib.${system});
        };

        devShells.default = pkgs.mkShell
          {
            buildInputs = attrValues {
              inherit (deploy-rs.packages.${system}) deploy-rs;
              inherit (pkgs)
                nixpkgs-fmt
                nil
                nixd
                ;
            };
            inherit (self.checks.${ system}.pre-commit-check) shellHook;
          };
      }) // {
      nixosConfigurations = {
        rpi4 = mkSystem "rpi4" aarch64-linux [
          ./hosts/rpi4/configuration.nix
        ];
        x1 = mkSystem "x1" x86_64-linux [
          ./hosts/x1/configuration.nix
        ];
        desktop = mkSystem "desktop" x86_64-linux [
          ./hosts/desktop/configuration.nix
        ];
        ws-10 = mkSystem "ws-10" x86_64-linux [
          ./hosts/desktop/configuration.nix
        ];
      };

      deploy.nodes =
        let
          lib = nixpkgs.lib;
          tailscaleHostname = hostname: lib.strings.concatStringsSep "." [ hostname "tail1968e" "ts" "net" ];
          activateArm = deploy-rs.lib.${aarch64-linux}.activate;
          inherit (deploy-rs.lib.${x86_64-linux}) activate;
          cfg = self.nixosConfigurations;
          system = s: s // {
            sshUser = "alain";
            user = "root";
            magicRollback = false;
            interactiveSudo = true;
            fastConnection = true;
          };
        in
        {
          rpi4 = {
            hostname = tailscaleHostname "rpi4";
            profiles = {
              system = system {
                path = activateArm.nixos cfg.rpi4;
                magicRollback = false;
                autoRollback = true;
                fastConnection = false;
              };
            };
          };
          x1 = {
            hostname = "x1";
            profiles = {
              system = system {
                path = activate.nixos cfg.x1;
                magicRollback = false;
                autoRollback = true;
                fastConnection = true;
              };
            };
          };
          desktop = {
            hostname = tailscaleHostname "desktop";
            profiles = {
              system = system {
                path = activate.nixos cfg.desktop;
                magicRollback = false;
                autoRollback = false;
                fastConnection = true;
                remoteBuild = false;
              };
            };
          };
          ws-10 = {
            hostname = tailscaleHostname "ws-10";
            profiles = {
              system = system {
                path = activate.nixos cfg.ws-10;
                magicRollback = false;
                autoRollback = false;
                fastConnection = false;
                remoteBuild = true;
              };
            };
          };
        };
    };
}
