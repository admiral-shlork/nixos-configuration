{ config, modulesPath, pkgs, ... }:

{
  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "vmd" "nvme" "ahci" "usb_storage" "usbhid" "sd_mod" ];
      kernelModules = [ ];
      systemd.enable = true;
    };
    kernelModules = [ "kvm-intel" ];
    # kernelPackages = pkgs.linuxPackages_latest;
    extraModulePackages = [ ];
    extraModprobeConfig = ''
      options snd_hda_intel power_save=0 power_save_controller=N
    '';
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/root";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  };
}
