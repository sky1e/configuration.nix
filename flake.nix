{
  description = "Twilight-Sparkle flake configuration";

  inputs = {
    nixpkgs = { url = "github:NixOS/nixpkgs/nixos-unstable"; };
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

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      inherit (nixpkgs) lib;
      hosts = {
        izzy-moonbow = { networking.hostName = "Izzy-Moonbow"; };
        twilight-sparkle = { networking.hostName = "twilight-sparkle"; };
      };
    in {
      nixosConfigurations = lib.mapAttrs (key: value:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ ./configuration.nix ({ ... }: value) ];
          specialArgs = inputs // {
            inherit hosts;
            host = value;
          };
        }) hosts;
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt;
    };
}
