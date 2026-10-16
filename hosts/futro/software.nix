{ config, lib, pkgs, ... }:
{
  services = {
    adguardhome = {
      enable = true;
      host = "0.0.0.0";
      port = 3000;
    };
    openssh.enable = true;
    xserver = {
      enable = false;
      xkb = {
        layout = "pl";
        variant = "";
      };
    };
  };

  environment.systemPackages = with pkgs; [ adguardhome htop ];
}
