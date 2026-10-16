{ config, pkgs, lib, modulesPath, ... }:

{
  virtualisation = {
    libvirtd = {
      enable = true;
    };
  };
  hardware.nvidia-container-toolkit.enable = true;
  users.groups.libvirtd.members = ["root" "whatever" ];
}
