{ config, lib, modulesPath, pkgs, ... }:

{
  networking = {
    hostName = "tiny-slab-beta";
    useDHCP = lib.mkDefault true;
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [ 80 9000 ];
      allowedUDPPorts = [ ];
    };
  };
}
