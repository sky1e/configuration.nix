{
  description = "Twilight-Sparkle flake configuration";

  inputs = {
    nixpkgs = { url = "github:NixOS/nixpkgs/nixos-unstable"; };
    skye-config = { url = "/home/skye/.config/nixpkgs/"; flake = false; };
    secrets = {
      url = "git+file:///home/skye/secrets/";
      flake = false;
    };
    system-common = {
      url = "git+ssh://git@github.com/mildlyfunctionalgays/system-common";
      flake = false;
    };
    tshock = {
      url = "github:sky1e/tshock-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, tshock, ... } @ inputs:
  let
    system = "x86_64-linux";
  in
  {
    nixosConfigurations = {
      twilight-sparkle = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          tshock.nixosModules.tshock
          #ignoreme
        ];
        specialArgs = inputs;
      };
    };
  };
}
