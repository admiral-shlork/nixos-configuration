{ config, lib, modulesPath, pkgs, ... }:

{
  networking = {
    hostName = "virtual-slab";
    hostId = "8434f22d";
    useDHCP = lib.mkDefault true;
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [ 9000 ];
      allowedUDPPorts = [ ];
    };
  };
}
