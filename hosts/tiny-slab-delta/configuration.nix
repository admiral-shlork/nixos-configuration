{ ... }:

#
# Lenovo ThinkCentre Tiny M70q Gen 2
# Intel(R) i5-11400T (6 cores)
# 32GB RAM (16+16)
#

{
  imports =
    [
      ../../common/alloy.nix
      ../../common/cadvisor.nix
      ../../common/kubernetes.nix
      ../../common/misc.nix
      ../../common/prometheus.nix
      ../../common/software.nix
      ../../common/virtualisation.nix
      ./hardware.nix
      ./kubernetes.nix
      ./misc.nix
      ./networking.nix
      ./printing.nix
      ./software.nix
      ./storage.nix
    ];
}
