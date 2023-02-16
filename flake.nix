{
  description = "Twilight-Sparkle flake configuration";

  inputs = {
    nixpkgs = { url = "github:NixOS/nixpkgs/nixos-unstable"; };
    skye-config = { url = "/home/skye/.config/nixpkgs/"; flake = false; };
    secrets = {
      url = "/etc/nixos/secrets/";
      flake = false;
    };
    system-common = {
      url = "git+ssh://git@github.com/mildlyfunctionalgays/system-common";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, ... } @ inputs:
  let
    system = "x86_64-linux";
  in
  {
    nixosConfigurations = {
      twilight-sparkle = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          #ignoreme
        ];
        specialArgs = inputs;
      };
    };
  };
}
