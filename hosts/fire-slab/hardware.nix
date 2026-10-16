{ config, lib, modulesPath, pkgs, ... }:

{
  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    enableRedistributableFirmware = true;
    graphics = {
      enable = true;
      extraPackages = with pkgs; [ intel-media-driver vpl-gpu-rt ];
    };
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };

  services = {
    blueman.enable = true;
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.extraConfig."51-no-suspend" = {
        "monitor.alsa.rules" = [{
          matches = [{ "node.name" = "~alsa_output.*"; }];
          actions.update-props = { "session.suspend-timeout-seconds" = 0; };
        }];
      };
    };
  };

  security.rtkit.enable = true;
}
