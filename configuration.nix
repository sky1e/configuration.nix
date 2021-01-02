# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  inherit (builtins) readDir;
  inherit (pkgs) lib;
  inherit (lib.attrsets) filterAttrs mapAttrs' nameValuePair;
  inherit (lib.strings) hasSuffix removeSuffix;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./hardware-configuration-fix.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  #boot.tmpOnTmpfs = true;

  networking.hostName = "toymouse"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  fileSystems."/home/skye/Downloads" = {
    options = [ "uid=skye" "gid=users" "mode=700" ];
  };
  fileSystems."/home".options = [ "compress-force=zstd" ];
  fileSystems."/".options = [ "compress-force=zstd" ];
  fileSystems."/nix".options = [ "compress-force=zstd" ];

  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };
  services.pipewire.enable = true;

  services.udev.packages = [
    (with pkgs; writeTextFile {
        name = "uhk-udev-rules";
        text = builtins.readFile ./50-uhk60.rules;
        destination = "/etc/udev/rules.d/50-uhk60.rules";
    })
  ];
  environment.systemPackages = [ pkgs.ntfs3g pkgs.cifs-utils ];
  programs.adb.enable = true;
  programs.light.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  # networking.useDHCP = false;
  # networking.interfaces.wlp1s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  virtualisation.virtualbox.host.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 22000 ];
  networking.firewall.allowedUDPPorts = [ 21027 ];
  networking.firewall.enable = false;
  services.syncthing = {
    openDefaultPorts = true;
    enable = true;
    user = "skye";
    dataDir = config.users.users.skye.home;
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

  services.flatpak.enable = true;

  programs.sway = {
    enable = true;
  };
  programs.fish.enable = true;
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };
  services.nginx = {
    enable = true;
    virtualHosts."localhost" = {
      locations."/".root = "/home/skye/nginx";
      serverName = "localhost";
      default = true;
      root = "/home/skye/nginx";
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  hardware.cpu.intel.updateMicrocode = true;
  hardware.openrazer.enable = true;
  hardware.sane.enable = true;
  hardware.opengl.extraPackages = [ pkgs.vaapiIntel ];
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.enable = true;
  hardware.pulseaudio.support32Bit = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;

  users.mutableUsers = false;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  #users.users = let
  #  dir = readDir ./users;
  #  filtered = filterAttrs (name: value: (hasSuffix ".nix" name) && value == "regular") dir;
  #  mapped = mapAttrs' (name: _: nameValuePair (removeSuffix ".nix" name) (import (./users + ("/" + name)) { inherit config pkgs; })) filtered;
  #in mapped;
  users.users = {
    skye = import ./users/skye.nix { inherit config pkgs; };
  };
  #users.users.skye = {
  #  isNormalUser = true;
  #  extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #  shell = pkgs.fish;
  #  uid = 1000;
  #  hashedPassword = import ./password-hash.nix;
  #  packages = with config.users.users.skye; import (home + "/.config/nixpkgs/packages.nix") { pkgs = pkgs // {config = config // import (home + "/.config/nixpkgs/config.nix"); }; };
  #};
  #nixpkgs.config.allowUnfree = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
}

