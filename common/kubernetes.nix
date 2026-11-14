{ ... }:

let
  masterAddress = "argus";
  apiserverPort = 6443;
  nodes = {
    "10.0.0.110" = [ "argus" ];
    "10.0.0.111" = [ "slab" ];
    "10.0.0.112" = [ "tiny-slab-alpha" ];
    "10.0.0.113" = [ "tiny-slab-beta" ];
    "10.0.0.114" = [ "tiny-slab-delta" ];
  };
in

{
  networking = {
    hosts = nodes;
    firewall = {
      allowedTCPPorts = [ 10250 ];
      trustedInterfaces = [ "mynet" ];
    };
  };

  services.kubernetes = {
    inherit masterAddress;
    apiserverAddress = "https://${masterAddress}:${toString apiserverPort}";
    # Pod and service ranges must stay clear of the 10.0.0.0/24 LAN.
    clusterCidr = "10.244.0.0/16";
    easyCerts = true;

    apiserver = {
      securePort = apiserverPort;
      serviceClusterIpRange = "10.96.0.0/16";
    };

    addons.dns.enable = true;
  };
}
