{ config, lib, modulesPath, pkgs, ... }:

{
  hardware = {
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    enableAllFirmware = true;
    firmware = [ pkgs.linux-firmware ];
  };
}
