# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lanzaboote, nixos-hardware, lib, ... } @ args:
let
  jupyterLabDefaultPort = 8888;
  tex = (pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-tetex koma-script amsmath latexmk moderncv;
  });
in
{
  imports = [
    ../../modules/common.nix
    ../../modules/nvim.nix
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.common-pc-laptop-ssd
    nixos-hardware.nixosModules.lenovo-thinkpad-x1
    lanzaboote.nixosModules.lanzaboote
    ({ config, pkgs, lib, ... }: {
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
      let pianoteq = pkgs.callPackage ../../pkgs/pianoteq6/default.nix { };
      in
      {
        environment.systemPackages = [ pianoteq ];
      }
    )
  ];

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
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", \
     MODE="0666", \
     SYMLINK+="ftdi_%n" \
     RUN+="/${pkgs.bash}/bin/sh -c '${pkgs.coreutils}/bin/echo -n %k >/sys%p/driver/unbind'"
  '';

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "google-chrome"
      "spotify"
      "zoom"
      "teams"
      "slack"
      "slack-dark"
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."lvm".device = "/dev/disk/by-uuid/86f45bc0-dd5f-4a93-8b81-e3e825d40049";

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.hostName = "x1"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable =
    true; # Easiest to use and most distros use this by default.
  systemd.services.NetworkManager-wait-online.enable = false;

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    # keyMap = "sg";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    videoDrivers = [ "modesetting" ];
    desktopManager = {
      xfce.enable = true;
      xterm.enable = false;
    };
    displayManager.defaultSession = "xfce";
  };

  programs.thunar = {
    enable = true;
    plugins = builtins.attrValues {
      inherit (pkgs.xfce) thunar-archive-plugin thunar-volman;
    };
  };

  modules.nvim.enable = true;
  environment.variables = { EDITOR = "nvim"; };

  # Configure keymap in X11
  services.xserver.layout = "ch";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    extraConfig = ''
      load-module module-switch-on-connect
    '';
    package = pkgs.pulseaudioFull;
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    settings = { General = { Enable = "Source,Sink,Media,Socket"; }; };
  };
  services.blueman.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput = {
    enable = true;
    touchpad = { disableWhileTyping = true; };
  };

  security.sudo.execWheelOnly = true;

  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
    tctiEnvironment = {
      enable = true;
      interface = "tabrmd";
    };
  };

  users.users.alain = {
    isNormalUser = true;
    password = "";
    extraGroups = [ "wheel" "audio" "tss" "dialout" ];
    packages = (builtins.attrValues {
      inherit (pkgs)
        joplin-desktop
        calibre
        kicad
        ngspice
        spotify-unwrapped
        # teams
        remmina
        slack-dark
        element-desktop
        ;
      # inherit (pkgs.texlive.combine) scheme-full koma-script;
    }) ++ [ tex ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = builtins.attrValues
    {
      # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      inherit (pkgs)
        gnumake
        google-chrome
        tailscale
        direnv
        openvpn
        tpm2-abrmd
        tpm2-tools
        git
        unzip;
      inherit (pkgs.xfce)
        xfce4-volumed-pulse
        xfce4-screenshooter
        xfce4-cpufreq-plugin
        xfce4-systemload-plugin
        xfce4-pulseaudio-plugin
        xfce4-sensors-plugin;
      inherit (pkgs.cinnamon) xreader;
    };
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

  services.tailscale.enable = true;
  services.fprintd.enable = true;
  services.onedrive.enable = true;
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns = true;
    openFirewall = true;
  };
  # networking.firewall.allowedTCPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPortRanges = [{
      from = 32768;
      to = 60999;
    }];
    allowedUDPPorts = [ config.services.tailscale.port 12345 ];
    allowedTCPPorts = [ jupyterLabDefaultPort ];
  };

  fonts = {
    enableDefaultFonts = true;
    fonts = [ (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; }) ];
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
