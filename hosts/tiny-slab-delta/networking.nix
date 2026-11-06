{ config, lib, modulesPath, pkgs, ... }:

{
  networking = {
    hostName = "tiny-slab-delta";
    useDHCP = lib.mkDefault true;
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [ 9000 ];
      allowedUDPPorts = [ ];
      trustedInterfaces = [ ];
    };
  };
}
