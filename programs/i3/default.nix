{ config, pkgs, ... }:

rec {
  environment.etc."i3config".source = (pkgs.substituteAll {
    name = "i3-config";
    src = ./config;
    inherit (pkgs) alacritty zsh tmux dmenu fzf findutils;
    i3statusRust = pkgs.i3status-rust;
    i3 = services.xserver.windowManager.i3.package;
    i3statusConfig = ./i3status.toml;
  }).outPath;

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
      default = "i3";
      i3 = {
        enable = true;
        package = pkgs.i3-gaps;
        configFile = "/etc/i3config";
      };
    };
    synaptics = {
      enable = true;
      tapButtons = false;
      twoFingerScroll = true;
      accelFactor = "0.03";
    };
  };

  fonts.fonts = [ pkgs.font-awesome_4 pkgs.powerline-fonts ];
}
