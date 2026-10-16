{ config, lib, pkgs, ... }:
{
  services = {
    openssh.enable = true;
    xserver = {
      enable = false;
      xkb = {
        layout = "pl";
        variant = "";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    btop # redundant placeholder
  ];
}
