{ ... }:

#
# Lenovo ThinkCentre Tiny M710q
# i7-6700T @ 2.80GHz (4 cores)
# 24GB RAM (16+8)
#

{
  imports =
    [
      # common
      ../../common/misc.nix
      ../../common/prometheus.nix
      ../../common/software.nix
      ../../common/virtualisation.nix
      # host specific
      ./hardware.nix
      ./misc.nix
      ./networking.nix
      ./software.nix
      ./storage.nix
    ];
}
