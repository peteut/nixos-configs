{
  description = "My deploy-rs config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-22.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
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
    gomod2nix = {
      url = "github:tweag/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    hosts = {
      url = "github:StevenBlack/hosts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , deploy-rs
    , flake-utils
    , nixpkgs
    , nixpkgs-unstable
    , gitignore
    , pre-commit-hooks
    , nixos-hardware
    , gomod2nix
    , hosts
    } @inputs:
    let
      inherit (flake-utils.lib) eachSystem;
      inherit (flake-utils.lib.system) x86_64-linux aarch64-linux;
      inherit (gitignore.lib) gitignoreSource;
      inherit (import ./lib.nix { inherit (nixpkgs) lib; }) zipAttrs;
      # pkgsCross = import nixpkgs {
      #   crossSystem = nixpkgs.lib.systems.examples.aarch64-multiplatform;
      #   localSystem.system = x86_64-linux;
      # };

      mkSystem = hostName: system: modules:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ({ ... }: {
              networking.hostName = hostName;
            })
          ] ++ modules;
          specialArgs = inputs;
        };

    in
    eachSystem [ x86_64-linux aarch64-linux ]
      (system:
      let
        pkgs = import nixpkgs-unstable {
          localSystem = system;
          overlays = [ gomod2nix.overlays.default ];
        };
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
            pkgs.gomod2nix
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
      };

      deploy.nodes = {
        rpi4 = {
          hostname = "192.168.1.2";
          profiles = {
            system = {
              sshUser = "alain";
              path = deploy-rs.lib.${aarch64-linux}.activate.nixos
                self.nixosConfigurations.rpi4;
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
