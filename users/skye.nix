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
  uid = if (host == hosts.twilight-sparkle) then 1001 else 1000;
  hashedPassword = import (secrets + /password-hash.nix);
  packages =
    let
      home = config.users.users.skye.home;
    in
    import (skye-config + "/packages.nix") {
      pkgs = import nixpkgs {
        system = pkgs.system;
        config = import (skye-config + "/config.nix");
        overlays = import (skye-config + "/overlays.nix");
      };
    };
}
