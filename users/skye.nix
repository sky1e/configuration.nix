{
  config,
  pkgs,
  skye-config,
  nixpkgs,
  nixpkgs-master,
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
    "plugdev"
  ];
  shell = pkgs.fish;
  hashedPassword = import (secrets + /password-hash.nix);
  packages =
    let
      home = config.users.users.skye.home;
      pkgs-from-nixpkgs =
        nixpkgs:
        import nixpkgs {
          inherit (pkgs) system;
          config = import (skye-config + "/config.nix");
          overlays = import (skye-config + "/overlays.nix") ++ [ (self: super: { inherit pkgs-master; }) ];
        };
      pkgs-master = pkgs-from-nixpkgs nixpkgs-master;

    in
    import (skye-config + "/packages.nix") {
      pkgs = pkgs-from-nixpkgs nixpkgs;
    };
}
