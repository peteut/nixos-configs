# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, nixos-hardware, lib, ... }:
let
  magicDNS = "100.100.100.100";
  tailscaleNet = "alain-peteut.gmail.com.beta.tailscale.net";
in
{
  imports = [
    ../../modules/common.nix
    ../../modules/nvim.nix
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.lenovo-thinkpad-l13
  ];

  # services.fstrim.enable = true;
  # services.throttled.enable = true;
  # hardware.cpu.intel.updateMicrocode =
  #   config.hardware.enableRedistributableFirmware;

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "google-chrome"
      "spotify-unwrapped"
      "zoom"
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # boot = {
  #   kernelModules = [ "acpi_call" ];
  #   extraModulePackages = [ config.boot.kernelPackages.acpi_call ];
  # };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.hostName = "l380"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable =
    true; # Easiest to use and most distros use this by default.
  systemd.services.NetworkManager-wait-online.enable = false;

  networking = {
    # nameservers = [ magicDNS ];
    # search = [ tailscaleNet ];
  };
  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "sg";
    #   useXkbConfig = true; # use xkbOptions in tty.
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    videoDrivers = [ "modesetting" ];
    useGlamor = true;
    desktopManager = {
      xfce = {
        enable = true;
        # enableXfwm = false;
      };
      xterm.enable = false;
    };
    displayManager.defaultSession = "xfce";
  };

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     firefox
  #     thunderbird
  #   ];
  # };
  users.users.alain = {
    isNormalUser = true;
    password = "";
    extraGroups = [ "wheel" "audio" ];
    packages = builtins.attrValues {
      inherit (pkgs)
        joplin-desktop calibre kicad spotify-unwrapped zoom-us remmina nerdfonts;
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = builtins.attrValues (lib.recursiveUpdate
    {
      # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      inherit (pkgs) git nixfmt google-chrome tailscale;
    }
    { inherit (pkgs.xfce) xfce4-volumed-pulse xfce4-screenshooter; });

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
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
    permitRootLogin = "no";
  };

  services.tailscale = { enable = true; };

  # Open ports in the firewall.
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
    allowedUDPPorts = [ config.services.tailscale.port ];
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
  system.stateVersion = "22.05"; # Did you read the comment?

}
