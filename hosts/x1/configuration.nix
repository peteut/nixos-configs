# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, lib, pkgsUnstable, inputs, ... }:
{
  imports = [
    ../../modules
    ../../modules/eee.nix
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1
    inputs.lanzaboote.nixosModules.lanzaboote
    ({ pkgs, lib, ... }: {
      # boot.bootspec.enable = true;
      environment.systemPackages = builtins.attrValues {
        inherit (pkgs) sbctl;
      };
      # Lanzaboote currently replaces the sytemd-boot module.
      boot.loader.systemd-boot.enable = lib.mkForce false;
      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/etc/secureboot";
      };
    })
    ({ pkgs, ... }:
      let pianoteq = pkgs.callPackage ../../pkgs/pianoteq/default.nix { };
      in
      {
        environment.systemPackages = [ pianoteq ];
      }
    )
    inputs.stylix.nixosModules.stylix
  ];

  config = {
    modules = {
      nvim.enable = true;
      musnix.enable = true;
      tailscale.enable = true;
      tex.enable = true;
    };

    virtualisation = {
      podman = {
        enable = true;
        dockerCompat = true;
        autoPrune.enable = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    };

    services.udev.extraRules = ''
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6014", \
       ATTRS{serial}=="210299AD07E3", \
       MODE="0666", \
       SYMLINK+="jtag-hs3_%n" \
       RUN+="/${pkgs.bash}/bin/sh -c '${pkgs.coreutils}/bin/echo -n %k >/sys%p/driver/unbind'"
      # STMicroelectronics STLINK-V3
      ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374d", MODE="0666", \
        TAG+="uaccess"
      ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374e", MODE="0666", \
        TAG+="uaccess"
      ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374f", MODE="0666", \
        TAG+="uaccess"
      ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3753", MODE="0666", \
        TAG+="uaccess"
      # RIOT standard peripherals: https://pid.codes/1209/7D00/
      ATTRS{idVendor}=="1209", ATTRS{idProduct}=="7d00", MODE="0666", \
        TAG+="uaccess"
      # RIOT riotboot DFU bootloader: https://pid.codes/1209/7D02/
      ATTRS{idVendor}=="1209", ATTRS{idProduct}=="7d02", MODE="0666", \
        TAG+="uaccess"
      # SUBSYSTEMS=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", \
      #   MODE="0666", \
      #   SYMLINK+="ftdi_%n" \
      #   RUN+="/${pkgs.bash}/bin/sh -c '${pkgs.coreutils}/bin/echo -n %k >/sys%p/driver/unbind'"
    '';

    stylix = {
      enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
      image = ./assets/nord-nixos.png;
    };

    nixpkgs.config = {
      allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          "google-chrome"
          "spotify"
          "zoom"
          "teams"
          "slack"
          "mongodb-ce"
        ];
    };

    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.initrd.luks.devices."lvm".device = "/dev/disk/by-uuid/063d8986-03e5-43d2-be6e-42d3092c12d5";

    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    networking.hostName = "x1"; # Define your hostname.
    # Pick only one of the below networking options.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    networking.networkmanager.enable =
      true; # Easiest to use and most distros use this by default.
    systemd.services.NetworkManager-wait-online.enable = false;

    # Enable the X11 windowing system.
    services.xserver = {
      enable = true;
      videoDrivers = [ "modesetting" ];
      desktopManager = {
        xfce.enable = true;
        xterm.enable = false;
      };
    };
    services.displayManager = {
      enable = true;
      defaultSession = "xfce";
    };
    services.picom = {
      enable = true;
      fade = true;
      inactiveOpacity = 0.9;
      shadow = false;
      fadeDelta = 4;
      vSync = true;
    };
    programs.hyprland.enable = true;
    programs.thunar = {
      enable = true;
      plugins = builtins.attrValues {
        inherit (pkgs.xfce) thunar-archive-plugin thunar-volman;
      };
    };

    services = {
      tlp = {
        enable = true;
        settings = {
          START_CHARGE_THRESH_BAT0 = 40;
          STOP_CHARGE_THRESH_BAT0 = 80;
          CPU_BOOST_ON_AC = 1;
          CPU_BOOST_ON_BAT = 0;
          CPU_HWP_DYN_BOOST_ON_AC = 1;
          CPU_HWP_DYN_BOOST_ON_BAT = 0;
          CPU_ENERGY_PERF_POLICY_ON_AC = "balanced_performance";
          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
          PLATFORM_PROFILE_ON_AC = "balanced";
          PLATFORM_PROFILE_ON_BAT = "low-power";
          RUNTIME_PM_ON_AC = "auto";
          RUNTIME_PM_ON_BAT = "auto";
          WIFI_PWR_ON_AC = "on";
          WIFI_PWR_ON_BAT = "on";
        };
      };
      fwupd.enable = true;
      # Configure keymap in X11
      xserver.xkb.layout = "ch";

      pulseaudio = {
        enable = false;
        extraConfig = ''
          load-module module-switch-on-connect
        '';
        package = pkgs.pulseaudioFull.override { jackaudioSupport = true; };
      };
      jack = {
        jackd.enable = false;
        alsa.enable = false;
      };
      pipewire = {
        enable = true;
        audio.enable = true;
        jack.enable = true;
        pulse.enable = true;
        alsa.enable = true;
        extraConfig = {
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
        wireplumber.extraConfig.bluetoothEnhancements = {
          "monitor.bluez.properties" = {
            "bluez5.roles" = [ "a2dp_sink" "a2dp_source" "bap_sink" "bap_source" "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
            "bluez5.codecs" = [ "sbc" "sbc_xq" "aac" ];
            "bluez5.enable-sbc-xq" = true;
            "bluez5.hfphsp-backend" = "native";
          };
        };
      };
    };

    hardware = {
      graphics = {
        enable = true;
        extraPackages = builtins.attrValues {
          inherit (pkgs) intel-media-driver;
        };
      };
      bluetooth = {
        enable = true;
        settings = { General = { Enable = "Source,Sink,Media,Socket"; }; };
      };
    };
    services.blueman.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    services.libinput = {
      enable = true;
      touchpad = { disableWhileTyping = true; };
    };

    security = {
      tpm2 = {
        enable = true;
        pkcs11.enable = true;
        # abrmd.enable = true;
        tctiEnvironment = {
          enable = true;
          interface = "tabrmd";
        };
      };
      sudo.execWheelOnly = true;
      rtkit.enable = true;
    };

    users.users.alain = {
      isNormalUser = true;
      password = "";
      extraGroups = [ "wheel" "audio" "jackaudio" "tss" "dialout" ];
      packages = (builtins.attrValues {
        inherit (pkgs)
          calibre
          spotify-unwrapped
          # teams
          remmina
          slack
          element-desktop
          pavucontrol
          qpwgraph
          ;
        inherit (pkgsUnstable) joplin-desktop;
      }) ++ [ pkgs.pipewire.jack ];
    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = (builtins.attrValues
      {
        # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
        inherit (pkgs)
          git
          gnumake
          google-chrome
          direnv
          openvpn
          tpm2-abrmd
          tpm2-tools
          unzip
          pulseaudioFull
          xreader;
        inherit (pkgs.xfce)
          xfce4-volumed-pulse
          xfce4-screenshooter
          xfce4-cpufreq-plugin
          xfce4-systemload-plugin
          xfce4-pulseaudio-plugin
          xfce4-sensors-plugin;
      });
    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    services.fprintd.enable = true;
    services.onedrive.enable = true;
    services.printing.enable = true;
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    # services.flatpak.enable = true;

    fonts = {
      enableDefaultPackages = true;
      packages = (builtins.attrValues { inherit (pkgs.nerd-fonts) jetbrains-mono; });
    };
  };
}
