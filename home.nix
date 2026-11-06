{ config, lib, pkgs, osConfig, ... }:

let
  hostName = osConfig.networking.hostName;
in

{
  imports =
    [ ./home/starship.nix ]
    ++ lib.optionals (hostName == "slab") [ ./home/slab.nix ]
    ++ lib.optionals (hostName == "tiny-slab-tri") [ ./home/tiny-slab-tri.nix ];

  # Home Manager configuration options go here
  home = {
    username = "whatever";
    homeDirectory = "/home/whatever";
    stateVersion = "25.11";
    packages = with pkgs; [ ];
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      alias ll='ls -alhF'
      alias la='ls -A'
      alias l='ls -CF'
    '';
  };
}
