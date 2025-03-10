{ config, lib, ... }:

{
  config = lib.mkIf (config.networking.hostName == "toymouse") {
    boot.initrd.luks.devices."${config.networking.hostName}".device =
      "/dev/disk/by-uuid/3da8181d-7347-4db7-be5d-dd46160ab2d2";
  };
}
