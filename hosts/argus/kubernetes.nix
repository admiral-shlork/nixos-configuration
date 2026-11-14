{ ... }:

{
  networking.firewall.allowedTCPPorts = [ 6443 8888 ];

  services.kubernetes = {
    roles = [ "master" ];
    apiserver.advertiseAddress = "10.0.0.110";
    kubelet.extraOpts = "--fail-swap-on=false";
  };
}
