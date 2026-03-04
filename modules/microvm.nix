{ pkgs, lib, config, inputs, ... }:
let
  cfg = config.modules.microvm;
  inherit (lib) mkEnableOption mkIf mkOption types;
  brName = "microbr";

  # Parse a whitelist text file: ignore blank lines and lines starting with '#'.
  parseWhitelist = file:
    builtins.filter
      (s: s != "" && !(lib.hasPrefix "#" s))
      (lib.splitString "\n" (builtins.readFile file));

  fileDomains =
    lib.optionals
      (cfg.dnsFilter.enable && cfg.dnsFilter.whitelistFile != null)
      (parseWhitelist cfg.dnsFilter.whitelistFile);

  allDomains = fileDomains ++ cfg.dnsFilter.allowedDomains;
in
{
  imports = [
    inputs.microvm.nixosModules.host
  ];
  options.modules.microvm = {
    enable = mkEnableOption "microvm";
    externalInterface = mkOption {
      type = types.str;
      description = "External interface for NAT.";
    };
    dnsFilter = {
      enable = mkEnableOption "DNS whitelist filter for VMs";
      whitelistFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          Path to a whitelist text file (one domain per line, # for comments).
          Subdomains are automatically included by dnsmasq.
        '';
        example = "./microvm/dns-whitelist.txt";
      };
      allowedDomains = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          Extra domains to allow, merged with whitelistFile.
          Useful for per-host overrides without editing the shared file.
        '';
        example = [ "example.com" ];
      };
    };
  };
  config = lib.mkMerge [
    {
      microvm.host.enable = cfg.enable;
    }
    (mkIf cfg.enable {
      environment.systemPackages = builtins.attrValues {
        inherit (pkgs) virtiofsd
          ;
      };
      networking =
        {
          bridges."${brName}".interfaces = [
          ];
          interfaces."${brName}".ipv4.addresses = [{
            address = "192.168.83.1";
            prefixLength = 24;
          }];
          nat = {
            enable = true;
            internalInterfaces = [ brName ];
            inherit (cfg) externalInterface;
          };
        };
      # Automatically attach any *-tap interface to the bridge via udev
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="net", KERNEL=="*-tap", \
          RUN+="${pkgs.iproute2}/bin/ip link set %k master ${brName}"
      '';
      # DNS for VMs: forward to systemd-resolved stub, with optional whitelist.
      services.dnsmasq = {
        enable = true;
        settings = {
          interface = brName;
          bind-interfaces = true;
          no-resolv = true;
          # When filtering: per-domain server entries only (no default upstream).
          # When not filtering: forward everything to systemd-resolved.
          server =
            if cfg.dnsFilter.enable
            then map (d: "/${d}/127.0.0.53") allDomains
            else [ "127.0.0.53" ];
        } // lib.optionalAttrs cfg.dnsFilter.enable {
          # Block all by default; server entries above override per domain.
          address = "/#/";
        };
      };
      networking.firewall.interfaces."${brName}" = {
        allowedUDPPorts = [ 53 ];
        allowedTCPPorts = [ 53 ];
      };
    })
  ];
}
