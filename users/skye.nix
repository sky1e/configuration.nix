{
  config,
  pkgs,
  skye-config,
  nixpkgs,
  secrets,
  host,
  hosts,
  ...
}:
{
  isNormalUser = true;
  extraGroups = [
    "docker"
    "wheel"
    "networkmanager"
    "scanner"
  ];
  shell = pkgs.fish;
  hashedPassword = import (secrets + /password-hash.nix);
  packages =
    let
      home = config.users.users.skye.home;
      inherit (skye-config) lib;
    in
    lib.packages {
      pkgs = import nixpkgs {
        inherit (pkgs) system;
        inherit (lib) config overlays;
      };
    };
}
