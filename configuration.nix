# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  lib,
  pkgs,
  system-common,
  host,
  hosts,
  ...
}@inputs:

let
  inherit (builtins) readDir;
  inherit (lib.attrsets) filterAttrs mapAttrs' nameValuePair;
  inherit (lib.strings) hasSuffix removeSuffix;
in
{

  #nixpkgs.config.allowBroken = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.memtest86.enable = true;
    efi.canTouchEfiVariables = true;
  };

  fileSystems = {
    "/home/skye/Downloads" = {
      mountPoint = "/home/skye/Downloads";
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "uid=skye"
        "gid=users"
        "mode=700"
      ];
    };
    "/luna" = {
      device = "10.69.0.69:/media/tank";
      fsType = "nfs4";
      options = [
        "x-systemd.automount"
        "noauto"
      ];
    };
  };

  services.udev.packages = [
    pkgs.platformio-core.udev
    pkgs.openocd
  ];

  nix = {
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "@wheel" ];
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        userServices = true;
      };
    };
    flatpak.enable = true;
    fprintd.enable = true;
    libinput.enable = true;
    pulseaudio.support32Bit = true;

    #hardware.xow.enable = true;
    openssh.enable = true;
    pipewire.enable = true;

    syncthing = {
      openDefaultPorts = true;
      enable = true;
      user = "skye";
      dataDir = config.users.users.skye.home;
    };
    yubikey-agent.enable = true;
  };

  environment.systemPackages = with pkgs; [
    gparted
    ntfs3g
    cifs-utils
    nfs-utils
  ];

  programs = {
    adb.enable = true;
    light.enable = true;
    nix-ld.enable = true;
    appimage = {
      binfmt = true;
      enable = true;
      package = pkgs.appimage-run.override { extraPkgs = pkgs: [ pkgs.libepoxy ]; };
    };
    fish.enable = true;
    ns-usbloader.enable = true;
    gamescope.enable = true;
    steam.gamescopeSession.enable = true;
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  # networking.useDHCP = false;
  # networking.interfaces.wlp1s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  # virtualisation.virtualbox.host.enable = true;

  networking = {
    firewall = {
      allowedTCPPorts = [
        80
        22000
      ];
      allowedUDPPorts = [ 21027 ];
      enable = false;
    };
    hosts =
      let
        inherit (pkgs.lib)
          attrValues
          foldl
          mapAttrs'
          nameValuePair
          ;
        hostsFile = import (system-common + /hosts.nix) { };
        subnets = attrValues hostsFile;
        hostsAttrSet = foldl (a: b: a // b) { } (map (a: a.hosts) subnets);
        hosts = mapAttrs' (name: value: lib.nameValuePair value.ip4 [ name ]) hostsAttrSet;
      in
      hosts;
  };
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #  fish
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  hardware.sane.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.steam-hardware.enable = true;
  hardware.xpadneo.enable = true;

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = false;
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };

  services.xserver = {
    #screenSection = if (host == hosts.twilight-sparkle) then ''
    #  Device         "Device0"
    #  Monitor        "Monitor0"
    #  DefaultDepth    24
    #  Option         "Stereo" "0"
    #  Option         "nvidiaXineramaInfoOrder" "DFP-4"
    #  Option         "metamodes" "2560x1440_144 +0+0"
    #  Option         "SLI" "Off"
    #  Option         "MultiGPU" "Off"
    #  Option         "BaseMosaic" "off"
    #  SubSection     "Display"
    #      Depth       24
    #  EndSubSection
    #'' else "";
    # Enable the X11 windowing system.
    enable = true;
    xkb.layout = "us";
    windowManager.i3.enable = true;
  };

  virtualisation.docker.enable = true;

  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "nvidia-persistenced"
      "nvidia-settings"
      "nvidia-x11"
      "steam-original"
    ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.packageOverrides = pkgs: {
    xsaneGimp = pkgs.xsane.override { gimpSupport = true; };
  };

  users = {
    mutableUsers = false;
    users = {
      skye = import ./users/skye.nix inputs;
    };
    groups.plugdev = {
      members = [ "skye" ];
    };
  };
  # Define a user account. Don't forget to set a password with ‘passwd’.
  #nixpkgs.config.allowUnfree = true;
  #boot.kernelPackages = pkgs.linuxPackages_latest;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
}
