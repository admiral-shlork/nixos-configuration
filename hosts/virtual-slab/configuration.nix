{ ... }:

#
# Hyper-V virtual machine
# Generation 2 with Secure Boot disabled
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
