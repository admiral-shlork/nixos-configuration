{ ... }:

#
# Mele Quieter 2Q 81A
# Celeron J4125 (4 cores)
# 8GB RAM
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
