{ ... }:
{
  services.cadvisor = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = 8081;
    extraOptions = [
      "--docker_only=true"
      "--housekeeping_interval=30s"
    ];
  };

  networking.firewall.allowedTCPPorts = [ 8081 ];

  systemd.services.cadvisor.serviceConfig = {
    Restart = "always";
    RestartSec = 2;
  };
}
