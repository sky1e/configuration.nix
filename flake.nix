{
  description = "Twilight-Sparkle flake configuration";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    skye-config = {
      url = "/home/skye/.config/nixpkgs/";
      flake = false;
    };
    secrets = {
      url = "git+file:///home/skye/secrets/";
      flake = false;
    };
    system-common = {
      url = "git+ssh://git@github.com/mildlyfunctionalgays/system-common";
      flake = false;
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      inherit (nixpkgs) lib;
      hosts = {
        izzy-moonbow = {
          networking.hostName = "Izzy-Moonbow";
          imports = [
            ./configuration.nix
            ./Izzy-Moonbow-hardware-configuration.nix
          ];
        };
        twilight-sparkle = {
          networking.hostName = "twilight-sparkle";
          imports = [
            ./configuration.nix
            ./hardware-configuration.nix
            ./hardware-configuration-fix.nix
          ];
          hardware.nvidia.open = false;
        };
      };
    in
    {
      nixosConfigurations = lib.mapAttrs (
        key: value:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ({ ... }: value) ];
          specialArgs = inputs // {
            inherit hosts;
            host = value;
          };
        }
      ) hosts;
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;
    };
}
