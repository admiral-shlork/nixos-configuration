{ ... }:

{
  networking.firewall.allowedTCPPorts = [ 6443 8888 ];

  services.kubernetes = {
    roles = [ "master" ];
    apiserver.advertiseAddress = "10.0.0.42";
  };
}
