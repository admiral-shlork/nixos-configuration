{ config, lib, modulesPath, pkgs, ... }:

{
  networking = {
    hostName = "virtual-slab";
    useDHCP = lib.mkDefault true;
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [ 9000 ];
      allowedUDPPorts = [ ];
    };
  };
}
