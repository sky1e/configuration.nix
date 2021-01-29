{ config, pkgs, ... }:
{
  isNormalUser = true;
  extraGroups = [ "wheel" "networkmanager" ];
  shell = pkgs.fish;
  uid = 1001;
  hashedPassword = import ../secrets/password-hash.nix;
  packages = let home = config.users.users.skye.home;
  in import (home + "/.config/nixpkgs/packages.nix" ) {
    pkgs = import <nixpkgs> {
      config = import (home + "/.config/nixpkgs/config.nix");
      overlays = import (home + "/.config/nixpkgs/overlays.nix");
    };
  };
}
