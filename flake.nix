{
  description = "Twilight-Sparkle flake configuration";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };
  };

  outputs = { self, nixpkgs, ... }:
  let ignoreme = ({config, lib, ...}: with lib; { system.nixos.revision = mkForce null; system.nixos.versionSuffix = mkForce "pre-git"; });
  in
  {
    nixosConfiguration = {
      twilight-sparkle = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ignoreme
        ];
        specialArgs = {
          inherit nixpkgs;
        };
      };
    };
  };
}
