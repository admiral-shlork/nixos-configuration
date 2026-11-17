{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    btop
    cryptsetup
    docker
    git
    ghostty.terminfo
    home-manager
    nh
    python3
    screen
    vim
    wget
  ];
}