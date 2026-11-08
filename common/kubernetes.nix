{ ... }:

let
  masterAddress = "futro";
  masterIp = "10.0.0.42";
  apiserverPort = 6443;
in

{
  networking = {
    hosts = {
      "${masterIp}" = [ masterAddress ];
    };
    firewall.allowedTCPPorts = [ 10250 ];
  };

  services.kubernetes = {
    inherit masterAddress;
    apiserverAddress = "https://${masterAddress}:${toString apiserverPort}";
    clusterCidr = "10.244.0.0/16";
    easyCerts = true;

    apiserver = {
      securePort = apiserverPort;
      serviceClusterIpRange = "10.96.0.0/16";
    };

    addons.dns.enable = true;
  };
}
