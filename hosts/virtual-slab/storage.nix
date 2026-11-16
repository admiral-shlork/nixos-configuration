{ config, modulesPath, pkgs, ... }:

{
  boot = {
    initrd = {
      availableKernelModules = [ "sd_mod" "sr_mod" ];
      systemd.enable = true;
    };
    kernelPackages = pkgs.linuxPackages;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = [ "zfs" ];
    zfs.forceImportRoot = false;
  };

  services.zfs.autoScrub.enable = true;

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
    "/home/whatever/mnt/storage" = {
      device = "zed/storage";
      fsType = "zfs";
      options = [ "nofail" ];
    };
  };
}
