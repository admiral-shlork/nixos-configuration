{ config, ... }:
{
  services.alloy = {
    enable = true;
    extraFlags = [
      "--server.http.listen-addr=127.0.0.1:12345"
      "--storage.path=/var/lib/alloy/data"
      "--disable-reporting"
    ];
  };

  environment.etc."alloy/config.alloy".source = ./alloy/config.alloy;

  systemd.services.alloy = {
    environment.ALLOY_HOST = config.networking.hostName;
    after = [ "docker.service" ];
    serviceConfig.SupplementaryGroups = [ "docker" ];
  };
}
