{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    btop
    docker
    git
    home-manager
    nh
    python3
    screen
    vim
    wget
  ];
}