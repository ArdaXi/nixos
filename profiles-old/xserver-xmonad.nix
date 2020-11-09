{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "compose:caps";
    displayManager = {
      slim.enable = false;
      lightdm = {
        enable = true;
        autoLogin = {
          enable = true;
          user = "ardaxi";
        };
        greeter.enable = false;
      };
    };
    desktopManager.xterm.enable = false;
    windowManager = {
      default = "xmonad";
      awesome.enable = true;
      xmonad = {
        enable = true;
        enableContribAndExtras = true;
        extraPackages = hPkgs: [ hPkgs.taffybar ];
      };
    };
    synaptics = {
      enable = true;
      tapButtons = false;
      twoFingerScroll = true;
      accelFactor = "0.03";
    };
  };
}
