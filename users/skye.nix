{ config, pkgs, skye-config, nixpkgs, secrets, ... }:
{
  isNormalUser = true;
  extraGroups = [ "docker" "wheel" "networkmanager" "scanner" ];
  shell = pkgs.fish;
  uid = 1001;
  hashedPassword = import (secrets + /password-hash.nix);
  packages =
    let home = config.users.users.skye.home;
    in import (skye-config + "/packages.nix" ) {
      pkgs = import nixpkgs {
        system = pkgs.system;
        config = import (skye-config + "/config.nix");
        overlays = import (skye-config + "/overlays.nix");
      };
    };
}
