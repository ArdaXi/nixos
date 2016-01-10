{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (texlive.combine {
      inherit (texlive) scheme-basic babel-dutch hyphen-dutch invoice fp;
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
    usbutils
    pciutils
    gnupg
    acpi
    steam
    (mpv.override { vaapiSupport = true; })
    xorg.xf86inputsynaptics
  ];

  networking.networkmanager.enable = true;
  networking.extraHosts = ''
    5.101.104.129 old-do
    178.62.236.168 do.ardaxi.com
  '';

  services.redshift = {
    enable = true;
    latitude = "52.37";
    longitude = "4.9";
  };

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

  hardware = {
    pulseaudio = { 
      enable = true;
      support32Bit = true;
    };
    opengl.driSupport32Bit = true;
  };

  security.setuidPrograms = [ "physlock" ];

  networking.firewall = {
    allowedTCPPorts = [ 10999 ];
    allowedUDPPorts = [ 10999 ];
  };
}
