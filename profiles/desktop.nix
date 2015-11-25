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
    firefox
    libreoffice
    chromium
    python34Packages.ipython
    arandr
    adobe-reader
    lyx
    ledger
    source-code-pro
    (mpv.override { vaapiSupport = true; })
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
  };

  services.physlock = {
    enable = true;
    user = "ardaxi";
  };

  security.setuidPrograms = [ "physlock" ];
}
