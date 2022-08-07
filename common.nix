{ nix.settings.trusted-public-keys = [ (builtins.readFile ./nix-pub.pem) ]; }
