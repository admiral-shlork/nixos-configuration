{ config, lib, modulesPath, pkgs, ... }:

{
  networking = {
    hostName = "argus";
    useDHCP = lib.mkDefault true;
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [ 80 88 2222 3000 5050 8080 8888 9090 6443 10257 10259 9000 ];
      allowedUDPPorts = [ 53 ];
    };
  };
}
