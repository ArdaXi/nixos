{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (texlive.combine {
      inherit (texlive) scheme-basic babel-dutch hyphen-dutch;
    })
    networkmanagerapplet
    e19.terminology
    taskwarrior
    fortune
    firefox-wrapper
    libreoffice
    chromium
    python34Packages.ipython
    arandr
    adobe-reader
    lyx
    ledger
    source-code-pro
    lighttable
    (mpv.override { vaapiSupport = true; })
    xorg.xf86inputsynaptics
  ];

  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "compose:caps";
    displayManager.slim = {
      defaultUser = "ardaxi";
      autoLogin = true;
    };
    desktopManager.xterm.enable = false;
    windowManager = {
      default = "awesome";
      awesome.enable = true;
    };
    synaptics = {
      enable = true;
      tapButtons = false;
      twoFingerScroll = true;
      accelFactor = "0.02";
    };
  };

  services.physlock = {
    enable = true;
    user = "ardaxi";
  };

  services.printing.enable = true;

  services.udev.extraRules = ''
    DRIVER=="snd_hda_intel", ATTR{power/control}="on"
  '';

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      source-code-pro
    ];
  };

  hardware.pulseaudio.enable = true;

  security.setuidPrograms = [ "physlock" ];
}
