{
  description = "Twilight-Sparkle flake configuration";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
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
    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      lix-module,
      nixpkgs-master,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      inherit (nixpkgs) lib;
      hosts = {
        izzy-moonbow =
          { ... }:
          {
            networking.hostName = "Izzy-Moonbow";
            imports = [
              ./configuration.nix
              ./Izzy-Moonbow-hardware-configuration.nix
            ];

            security.polkit.enable = true;
            environment.systemPackages = with pkgs; [ polkit_gnome ];
            users.users.skye.uid = 1000;
          };
        twilight-sparkle =
          { pkgs, ... }:
          {
            networking = {
              hostName = "twilight-sparkle";
              hostId = "d50a7f2e";
            };
            imports = [
              ./configuration.nix
              ./hardware-configuration.nix
              ./hardware-configuration-fix.nix
            ];
            boot.supportedFilesystems = [ "zfs" ];
            hardware.nvidia.open = false;
            fileSystems."/home/skye/Steam Library" = {
              options = [ "compress=zstd" ];
            };

            services.xserver.videoDrivers = [ "nvidia" ];
            services.nginx = {
              enable = true;
              virtualHosts."battlesnake.skye-c.at" = {
                root = "/var/www";
                listen = [
                  {
                    addr = "0.0.0.0";
                    port = 8080;
                  }
                ];
              };
              virtualHosts."localhost" = {
                locations."/".root = "/home/skye/nginx";
                serverName = "localhost";
                default = true;
                root = "/home/skye/nginx";
              };
            };
            users.users.artemis = {
              isSystemUser = true;
              uid = 1000;
              group = "users";
            };
            users.users.skye.uid = 1001;
          };
      };
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-master = nixpkgs-master.legacyPackages.${system};
    in
    {
      nixosConfigurations = lib.mapAttrs (
        key: value:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            lix-module.nixosModules.default
            ./configuration.nix
            value
            (
              { config, pkgs, ... }:
              {
                nixpkgs.overlays = [ (self: super: { inherit pkgs-master; }) ];
              }
            )
            #ignoreme
          ];
          specialArgs = inputs // {
            inherit hosts;
            host = value;
          };
        }
      ) hosts;
      formatter.${system} = pkgs.nixfmt-rfc-style;
    };
}
