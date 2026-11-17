{ config, lib, ... }:

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

  # certmgr adds every CN to the SAN list. For system:* CNs the issued
  # cert has no matching DNS SAN, so certmgr reissues it on every check.
  # That rotates the service-account key and invalidates all tokens.
  certSpec = _: cert: {
    inherit (cert) action;
    authority = {
      remote = "https://${config.services.kubernetes.masterAddress}:${toString config.services.cfssl.port}";
      root_ca = cert.caCert;
      profile = "default";
      auth_key_file = "${config.services.kubernetes.secretsPath}/apitoken.secret";
    };
    certificate.path = cert.cert;
    private_key = cert.privateKeyOptions;
    request = {
      CN = cert.CN;
      hosts = lib.filter (host: !(lib.hasPrefix "system:" host)) ([ cert.CN ] ++ cert.hosts);
      key = {
        algo = "rsa";
        size = 2048;
      };
      names = [ cert.fields ];
    };
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

  services.certmgr.specs = lib.mkForce (
    lib.mapAttrs certSpec config.services.kubernetes.pki.certs
  );
}
