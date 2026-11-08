{ ... }:

#
# Fujitsu Futro S940
# Pentium J5005 (4 cores)
# 16GB RAM
#

{
  imports =
    [
      ../../common/kubernetes.nix
      ../../common/misc.nix
      ../../common/prometheus.nix
      ../../common/software.nix
      ../../common/virtualisation.nix
      ./hardware.nix
      ./kubernetes.nix
      ./misc.nix
      ./networking.nix
      ./software.nix
      ./storage.nix
    ];
}
