# Dev VM

A NixOS microvm pre-configured for development, including Claude Code.

## Host requirements

The NixOS host must have the `modules.microvm` module enabled. To use it from a separate NixOS configs project, add this repo and `microvm.nix` as flake inputs, then import the module:

```nix
# flake.nix
{
  inputs = {
    nixos-configs = {
      url = "github:peteut/nixos-configs";
      flake = false;
    };
    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-configs, ... }@inputs: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; }; # required: module uses inputs.microvm
      modules = [
        "${nixos-configs}/modules/microvm.nix"
        {
          modules.microvm = {
            enable = true;
            externalInterface = "eth0"; # adjust to your uplink
          };
        }
      ];
    };
  };
}
```

This creates the `microbr` bridge, configures NAT, and auto-attaches tap interfaces.

## devenv.sh setup

See [devenv.sh](https://devenv.sh) for installation and setup. Define the VM as a process in `devenv.nix`:

```nix
{ pkgs, config, ... }: {
  processes.devvm.exec = "${pkgs.lib.getExe pkgs.nix} run path:.#devvm";
}
```

Start the VM:

```bash
devenv up
```

## Claude Code authentication

Claude Code requires `ANTHROPIC_API_KEY`. secretspec separates secret *declaration* from storage; each developer connects their preferred backend (system keyring, 1Password, dotenvx, etc.).

`secretspec` must be present in the devenv shell:

```nix
# devenv.nix
{ pkgs, ... }: {
  packages = [ pkgs.secretspec ];
}
```

1. Initialize and declare the secret in `secretspec.toml` — see the [secretspec quick start](https://secretspec.dev/quick-start/#1-initialize-secretspectoml). **Commit this file.**

   ```toml
   [ANTHROPIC_API_KEY]
   description = "Anthropic API key for Claude Code"
   required = true
   ```

   Example only — refer to the quick start for the full `secretspec init` workflow.

2. Each developer obtains their API key from the [Anthropic API console](https://platform.claude.com/docs/en/api/admin/api_keys/retrieve) and populates the secret via their backend once:

   ```bash
   secretspec set ANTHROPIC_API_KEY   # prompts, stores in configured backend
   ```

3. Wrap the devenv process so the secret is injected and written before VM start:

   ```nix
   # devenv.nix
   processes.devvm.exec = ''
     secretspec run -- sh -c '
       mkdir -p ~/.config/anthropic
       printf "%s" "$ANTHROPIC_API_KEY" > ~/.config/anthropic/api-key
       chmod 600 ~/.config/anthropic/api-key
       exec ${pkgs.lib.getExe pkgs.nix} run path:.#devvm
     '
   '';
   ```

## Passing the key into the VM

The key written above is made available inside the VM via a virtiofs share. Add this when instantiating the VM (e.g. in `flake.nix`):

```nix
packages.devvm = import ./microvm/dev.nix {
  inherit (inputs) microvm;
  inherit pkgs;
  inherit (nixpkgs) lib;
  hostName = "devvm";
  shares = [{
    tag = "anthropic-key";
    source = "/home/${username}/.config/anthropic";
    mountPoint = "/run/secrets/anthropic";
    proto = "virtiofs";
  }];
};
```

And export the key automatically inside the VM:

```nix
environment.etc."profile.d/anthropic.sh".text = ''
  if [ -r /run/secrets/anthropic/api-key ]; then
    export ANTHROPIC_API_KEY=$(cat /run/secrets/anthropic/api-key)
  fi
'';
```
