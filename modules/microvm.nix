{ pkgs, lib, config, inputs, ... }:
let
  cfg = config.modules.microvm;
  inherit (lib) mkEnableOption mkIf mkOption;
  brName = "microbr";
  tapName = "microvm";
in
{
  imports = [
    inputs.microvm.nixosModules.host
  ];
  options.modules.microvm = {
    enable = mkEnableOption "microvm";
    externalInterface = mkOption {
      type = lib.types.str;
      description = "External interface for NAT.";
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
      # DNS for VMs: forward to systemd-resolved stub.
      services.dnsmasq = {
        enable = true;
        settings = {
          interface = brName;
          bind-interfaces = true;
          no-resolv = true;
          server = [ "127.0.0.53" ];
        };
      };
      networking.firewall.interfaces."${brName}" = {
        allowedUDPPorts = [ 53 ];
        allowedTCPPorts = [ 53 ];
      };
    })
  ];
}
