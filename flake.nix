{
  description = "My deploy-rs config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix/release-25.11";
    };
    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell/v4.6.1";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.noctalia-qs.follows = "noctalia-qs";
    };
    noctalia-qs = {
      url = "github:noctalia-dev/noctalia-qs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , deploy-rs
    , flake-utils
    , nixpkgs
    , nixpkgs-unstable
    , ...
    }@inputs:
    let
      inherit (flake-utils.lib) eachSystem;
      inherit (flake-utils.lib.system) x86_64-linux aarch64-linux;

      username = "alain";

      mkPkgs =
        let
          inherit (builtins) elem;
          inherit (nixpkgs.lib) getName;
        in
        { system, extraOverlays ? [ ], extraUnfree ? [ ] }: import nixpkgs {
          inherit system;
          overlays = [
            (import ./overlays/pianoteq.nix)
            inputs.claude-code-nix.overlays.default
          ] ++ extraOverlays;
          config.allowUnfreePredicate = pkg:
            elem (getName pkg) ([
              "google-chrome"
              "slack"
              "pianoteq-stage"
              "claude-code"
            ] ++ extraUnfree);
        };

      mkSystem = hostName: system: modules:
        let
          pkgs = mkPkgs {
            inherit system;
          };
        in
        nixpkgs.lib.nixosSystem
          {
            inherit system pkgs;
            modules = [
              ./modules/system/configuration.nix
              {
                networking.hostName = hostName;
              }
            ] ++ modules;
            specialArgs = {
              inherit self inputs username;
              pkgsUnstable = nixpkgs-unstable.legacyPackages.${system};
            };
          };

    in
    eachSystem
      [ x86_64-linux aarch64-linux ]
      (system:
      let
        pkgs = mkPkgs {
          inherit system;
        };
        inherit (builtins)
          attrValues
          mapAttrs
          ;
        inherit (pkgs.lib)
          getExe
          ;

      in
      {
        checks = {
          pre-commit-check = inputs.git-hooks.lib.${system}.run
            {
              src = ./.;
              hooks = {
                nixpkgs-fmt.enable = true;
                nix-linter.enable = false;
                stylua.enable = true;
                dprint = {
                  enable = true;
                  description = "dprint formatter";
                  types = [ "text" ];
                  language = "system";
                  entry = "${getExe pkgs.dprint} fmt --allow-no-files";
                };
              };
            } // (mapAttrs
            (_: deployLib: deployLib.deployChecks self.deploy)
            deploy-rs.lib.${system});
        };

        packages.devvm = import ./microvm/dev.nix
          {
            inherit (inputs) microvm;
            inherit pkgs;
            inherit (nixpkgs) lib;
            hostName = "test-devvm";
            user = username;
          };

        devShells.default = pkgs.mkShell
          {
            buildInputs = attrValues {
              inherit (pkgs)
                deploy-rs
                nixpkgs-fmt
                nil
                nixd
                dotenvx
                sops
                dprint
                ;
              inherit (pkgs.dprint-plugins)
                dprint-plugin-markdown
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
        ws-27 = mkSystem "ws-27" x86_64-linux [
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
          ws-27 = {
            hostname = tailscaleHostname "ws-27";
            profiles = {
              system = system {
                path = activate.nixos cfg.ws-27;
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
