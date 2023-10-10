{ pkgs, ... }:
let atlc = pkgs.callPackage ../pkgs/atlc/default.nix { };
in { environment.systemPackages = [ atlc ]; }
