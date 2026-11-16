{ config, modulesPath, pkgs, ... }:

{
  boot = {
    initrd = {
      availableKernelModules = [ "sd_mod" "sr_mod" ];
      systemd.enable = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    zfs.enabled;
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
    "/" = {
      device = "/dev/disk/by-label/root";
      fsType = "ext4";
    };
  };
}
