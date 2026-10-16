{ ... }:

#
# Lenovo ThinkCentre Tiny M75Q
# Ryzen 5 PRO 3400GE (4 cores)
# 16GB RAM (8+8)
#

{
  imports =
    [
      ../../common/misc.nix
      ../../common/prometheus.nix
      ../../common/software.nix
      ../../common/virtualisation.nix
      ./hardware.nix
      ./misc.nix
      ./networking.nix
      ./software.nix
      ./storage.nix
    ];
}
