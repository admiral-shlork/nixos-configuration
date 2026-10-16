{ config, lib, modulesPath, pkgs, ... }:

{
  networking = {
    hostName = "tiny-slab-too";
    useDHCP = lib.mkDefault true;
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [ 80 9000 ];
      allowedUDPPorts = [ ];
    };
  };
}
