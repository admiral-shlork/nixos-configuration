{ config, lib, modulesPath, pkgs, ... }:

{
  networking = {
    hostName = "tiny-slab-one";
    useDHCP = lib.mkDefault true;
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [ 80 9000 ];
      allowedUDPPorts = [ ];
    };
  };
}
