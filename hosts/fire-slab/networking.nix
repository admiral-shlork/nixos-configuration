{ config, lib, modulesPath, pkgs, ... }:

{
  networking = {
    hostName = "fire-slab";
    useDHCP = lib.mkDefault true;
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [ 9000 ];
      allowedUDPPorts = [ ];
      trustedInterfaces = [ ];
    };
  };
}
