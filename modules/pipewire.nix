{ lib, config, pkgs, ... }:
let
  cfg = config.modules.pipewire;
  inherit (lib) mkEnableOption mkIf mkOption types;
  inherit (lib.attrsets) optionalAttrs;
  extraConfigDefault = {
    pipewire."91-null-sinks" = {
      "context.objects" = [
        {
          # A default dummy driver. This handles nodes marked with the "node.always-driver"
          # properyty when no other driver is currently active. JACK clients need this.
          factory = "spa-node-factory";
          args = {
            "factory.name" = "support.node.driver";
            "node.name" = "Dummy-Driver";
            "priority.driver" = 8000;
          };
        }
        {
          factory = "adapter";
          args = {
            "factory.name" = "support.null-audio-sink";
            "node.name" = "Main-Output-Proxy";
            "node.description" = "Main Output";
            "media.class" = "Audio/Sink";
            "audio.position" = "FL,FR";
          };
        }
      ];
    };
    pipewire-pulse."92-low-latency" = {
      context-objects = [
        {
          name = "libpipewire-module-protocol-pulse";
          args = {
            pulse.min.req = "32/48000";
            pulse.default.req = "32/48000";
            pulse.max.req = "32/48000";
            pulse.min.quantum = "32/48000";
            pulse.max.quantum = "32/48000";
          };
        }
      ];
      stream.properties = {
        node.latency = "32/48000";
        resample.quality = 1;
      };
    };
  };
  wireplumberExtraConfigBT = {
    bluetoothEnhancements = {
      "monitor.bluez.properties" = {
        "bluez5.roles" = [ "a2dp_sink" "a2dp_source" "bap_sink" "bap_source" "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
        "bluez5.codecs" = [ "sbc" "sbc_xq" "aac" ];
        "bluez5.enable-sbc-xq" = true;
        "bluez5.hfphsp-backend" = "native";
      };
    };
  };
in
{
  options.modules.pipewire = {
    enable = mkEnableOption "pipewire";
    enableBT = mkEnableOption "BT";
    extraConfig = mkOption {
      default = extraConfigDefault;
      type = types.attrs;
    };
  };

  config = mkIf cfg.enable {
    services = {
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        audio.enable = true;
        pulse.enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        inherit (cfg) extraConfig;
        wireplumber.extraConfig = optionalAttrs cfg.enableBT wireplumberExtraConfigBT;
      };
    };
    hardware.alsa.enablePersistence = true;
    environment.systemPackages = builtins.attrValues {
      inherit (pkgs) pulseaudioFull;
    };
  };
}

