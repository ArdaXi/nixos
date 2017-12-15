{ config, pkgs, ... }:

let
  mypkgs = pkgs // import ../pkgs;
in
{
  environment.systemPackages = with mypkgs; [
    (texlive.combine {
      inherit (texlive) scheme-basic babel-dutch hyphen-dutch invoice fp collection-latexrecommended xetex relsize collection-fontsrecommended xetex-def collection-htmlxml draftwatermark everypage;
    })
    gyre-fonts
    networkmanagerapplet
    enlightenment.terminology
    taskwarrior
    fortune
    firefox-beta-bin
    libreoffice
    google-chrome
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
    dmenu
    haskellPackages.xmobar
    xdotool
    ledger
    slock
    (dwarf-fortress.override { theme = "phoebus"; enableDFHack = true; })
    rustracer
#    rustChannels.stable.rust
    gcc
    rustfmt
    tahoelafs
    scrot
#    latest.firefox-nightly-bin
#    firefox-devedition-bin
#    latest.firefox-beta-bin
    #(wineFull.override { wineBuild = "wineWow"; })
    wineStaging
    winetricks
    taffybar
    glib_networking
    openconnect
    pass
    browserpass
    nfsUtils
    keybase
    vault
  ];

  networking.networkmanager = {
    enable = true;
    packages = [ pkgs.networkmanager_openconnect ];
    useDnsmasq = true;
  };

  services.redshift = {
    enable = true;
    latitude = "52.37";
    longitude = "4.9";
  };

  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "compose:caps";
    displayManager = {
      sessionCommands = ''
        taffybar &
      '';
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
	extraPackages = hPkgs: [
	  hPkgs.taffybar
	  hPkgs.DBus.override { buildDepends = [ "pkgconfig" "dbus" ]; }
	];
      };
    };
    synaptics = {
      enable = true;
      tapButtons = false;
      twoFingerScroll = true;
      accelFactor = "0.02";
    };
  };

  services.physlock.enable = true;

  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ];
  };

  services.pcscd.enable = true;

  services.udev.extraRules = ''
    DRIVER=="snd_hda_intel", ATTR{power/control}="on"
    SUBSYSTEM=="usb", ATTR{idVendor}=="1d50", ATTR{idProduct}=="cc15", MODE="0600", OWNER="ardaxi", GROUP="ardaxi"
    SUBSYSTEM=="usb", ATTR{idVendor}=="1d50", ATTR{idProduct}=="6089", MODE="0600", OWNER="ardaxi", GROUP="ardaxi"
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
    bluetooth.enable = true;
  };

  nixpkgs.config = {
    packageOverrides = pkgs: {
      bluez = pkgs.bluez5;
    };
  };

  services.upower.enable = true;

  services.avahi = {
    enable = true;
    nssmdns = true;
  };

  services.geoclue2.enable = true;

  security.wrappers.physlock.source = "${pkgs.physlock}/bin/physlock";

  networking.firewall = {
    allowedTCPPorts = [ 10999 8000 80 ];
    allowedUDPPorts = [ 10999 ];
  };

  networking.extraHosts = ''
    62.251.59.192  tahoe.ardaxi.com
  '';

  services.keybase.enable = true;
  services.kbfs.enable = true;
}
