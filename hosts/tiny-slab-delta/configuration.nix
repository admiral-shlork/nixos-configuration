{ ... }:

#
# Lenovo ThinkCentre Tiny M70q Gen 2
# Intel(R) i5-11400T (6 cores)
# 32GB RAM (16+16)
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
      ./printing.nix
      ./software.nix
      ./storage.nix
    ];
}
