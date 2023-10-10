{
  description = "My deploy-rs config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgsUnstable.url = "github:nixos/nixpkgs/nixos-unstable";
    lanzaboote.url = "github:nix-community/lanzaboote";
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    hosts = {
      url = "github:StevenBlack/hosts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , deploy-rs
    , flake-utils
    , nixpkgs
    , nixpkgsUnstable
    , lanzaboote
    , gitignore
    , pre-commit-hooks
    , nixos-hardware
    , hosts
    , nixos-wsl
    , nixvim
    }@inputs:
    let
      inherit (flake-utils.lib) eachSystem;
      inherit (flake-utils.lib.system) x86_64-linux aarch64-linux;
      inherit (gitignore.lib) gitignoreSource;
      # pkgsCross = import nixpkgs {
      #   crossSystem = nixpkgs.lib.systems.examples.aarch64-multiplatform;
      #   localSystem.system = x86_64-linux;
      # };

      mkSystem = hostName: system: modules:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [{ networking.hostName = hostName; }] ++ modules;
          specialArgs = inputs;
        };

    in
    eachSystem [ x86_64-linux aarch64-linux ]
      (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run
            {
              src = gitignoreSource ./.;
              hooks = {
                nixpkgs-fmt.enable = true;
                nix-linter.enable = false;
              };
            } // (builtins.mapAttrs
            (_: deployLib: deployLib.deployChecks self.deploy)
            deploy-rs.lib.${system});
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            deploy-rs.defaultPackage.${system}
            pkgs.nixpkgs-fmt
          ];
          inherit (self.checks.${system}.pre-commit-check) shellHook;
        };
      }) // {
      nixosConfigurations = {
        rpi4 = mkSystem "rpi4" aarch64-linux [
          ./hosts/rpi4/configuration.nix
          hosts.nixosModule
          {
            networking.stevenBlackHosts = {
              enable = true;
              blockFakenews = true;
              blockGambling = true;
              blockPorn = true;
            };
          }
        ];
        x1 =
          mkSystem "x1" x86_64-linux [
            ./hosts/x1/configuration.nix

            ({ pkgs, ... }:
              let pianoteq = pkgs.callPackage ./pkgs/pianoteq6/default.nix { };
              in
              {
                environment.systemPackages = [ pianoteq ];
              })

            # nixpkgsUnstable.nixosModules.bootspec

            # lanzaboote.nixosModules.lanzaboote

            # ({ config, pkgs, lib, ... }: {
            #   # boot.bootspec.enable = true;

            #   environment.systemPackages = builtins.attrValues {
            #     inherit (pkgs) sbctl;
            #   };
            #   # Lanzaboote currently replaces the sytemd-boot module.
            #   boot.loader.systemd-boot.enable = lib.mkForce false;

            #   boot.lanzaboote = {
            #     enable = true;
            #     pkiBundle = "/etc/secureboot";
            #   };
            # })
          ];
        desktop = mkSystem "desktop" x86_64-linux [
          ./hosts/desktop/configuration.nix
        ];
      };

      deploy.nodes = {
        rpi4 = {
          hostname = "rpi4.tail1968e.ts.net";
          profiles = {
            system = {
              path = deploy-rs.lib.${aarch64-linux}.activate.nixos self.nixosConfigurations.rpi4;
              sshUser = "alain";
              user = "root";
              sshOpts = [ "-t" ];
              magicRollback = false;
              autoRollback = true;
              fastConnection = true;
            };
          };
        };
        x1 = {
          hostname = "x1";
          profiles = {
            system = {
              path = deploy-rs.lib.${x86_64-linux}.activate.nixos self.nixosConfigurations.x1;
              sshUser = "alain";
              user = "root";
              sshOpts = [ "-t" ];
              magicRollback = false;
              autoRollback = true;
              fastConnection = true;
            };
          };
        };
        desktop = {
          hostname = "desktop.tail1968e.ts.net";
          profiles = {
            system = {
              path = deploy-rs.lib.${x86_64-linux}.activate.nixos self.nixosConfigurations.desktop;
              sshUser = "alain";
              user = "root";
              sshOpts = [ "-t" ];
              magicRollback = false;
              autoRollback = true;
              fastConnection = true;
            };
          };
        };
      };
    };
}
