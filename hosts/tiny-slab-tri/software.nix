{ config, lib, pkgs, ... }:

{
  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "ie";
        variant = "";
      };
    };
    keyd = {
      enable = true;
      keyboards.remote = {
        ids = [ "a604:0715" ];
        settings.main = {
          homepage = "leftmeta";
          compose = "f";
          backspace = "esc";
          power = "wakeup";
        };
      };
    };
    displayManager = {
      gdm.enable = true;
      autoLogin.enable = true;
      autoLogin.user = "whatever";
    };
    desktopManager.gnome.enable = true;
    udev.packages = with pkgs; [ gnome-settings-daemon ];
    openssh.enable = true;
    prometheus.exporters.node.enabledCollectors = [ "wifi" ];
  };

  systemd.services = {
    "getty@tty1".enable = false;
    "autovt@tty1".enable = false;
  };

  programs = {
    firefox.enable = true;
    chromium.enable = true;
    direnv.enable = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      brlaser
      chromium
      git
      dconf-editor
      direnv
      ghostty
      gnomeExtensions.appindicator
      gnomeExtensions.caffeine
      gnomeExtensions.dash-to-panel
      gnomeExtensions.date-menu-formatter
      gnomeExtensions.no-overview
      home-manager
      moonlight-qt
      nh
      pciutils
      plezy
      vim
      vivaldi
      vlc
      vscodium
      wget
    ];
    gnome.excludePackages =
      (with pkgs; [
      atomix
      cheese
      decibels
      epiphany
      evince
      geary
      gedit
      gnome-calendar
      gnome-connections
      gnome-console
      gnome-contacts
      gnome-maps
      gnome-music
      gnome-photos
      gnome-software
      gnome-terminal
      gnome-tour
      gnome-weather
      hitori
      iagno
      simple-scan
      showtime
      snapshot
      tali
      totem
      virt-manager
      yelp
      ]);
  };

  fonts.packages = [
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.droid-sans-mono
  ];
}
