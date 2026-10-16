{ ... }:

#
# Lenovo ThinkStation P520
# Intel Xeon X-2145 (8 cores)
# 72GB RAM (2x32 + 2x8)
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
      ./samba.nix
      ./software.nix
      ./storage.nix
      ./virtualisation.nix
    ];
}
