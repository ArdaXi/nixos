{ config, pkgs, ... }:

let
  mypkgs = pkgs // import ../pkgs;
in
{
  imports = [
#    ./xserver-xmonad.nix
#    ./sway.nix
    ../programs/i3
    ../programs/wikibase.nix
#    ../programs/st
    ../programs/mopidy.nix
    ../programs/alacritty.nix
    ../programs/yubikey.nix
#    ../programs/vpn.nix
#    ../programs/wireguard.nix
  ];

  environment.systemPackages = with mypkgs; [
    networkmanagerapplet
#    (networkmanagerapplet.override { withGnome = false; })
    (mpv.override { vaapiSupport = true; })
    alacritty taskwarrior fortune arandr adobe-reader lyx ledger
    source-code-pro lighttable usbutils pciutils gnupg acpi steam dmenu
    xorg.xf86inputsynaptics xdotool slock gcc scrot
    wineStaging winetricks taffybar glib_networking pass
    browserpass nfsUtils keybase pinentry_qt4 
#python3Packages.neovim
    alsaUtils keybase-gui riot-desktop firefox-beta-bin
    isync notmuch msmtp astroid afew libnotify
    tahoelafs google-chrome rustracer
    libreoffice gist signal-desktop
    rustup tomb exercism
    (texlive.combine {
      inherit (texlive) scheme-basic babel-dutch hyphen-dutch invoice fp collection-latexrecommended xetex relsize collection-fontsrecommended draftwatermark everypage qrcode geometry;
# collectionhtmlxml xetex-def
    })
  ];

  networking = {
    firewall = {
      allowedTCPPorts = [ 10999 8000 80 ];
      allowedUDPPorts = [ 10999 ];
    };

    extraHosts = ''
      192.168.178.2  tahoe.street.ardaxi.com
      192.168.178.2  sickrage.local.ardaxi.com
      192.168.178.2  sabnzbd.local.ardaxi.com
      192.168.178.2  local.ardaxi.com
    '';

    networkmanager = {
      enable = true;
      insertNameservers = [ "127.0.0.1" ];
#      dns = "dnsmasq";
    };
  };

  services = {
    dnsmasq = {
      enable = true;
      servers = [ "8.8.4.4" "8.8.8.8" "2001:4860:4860::8844" "2001:4860:4860::8844" ]; # Google
    };

    redshift = {
      enable = true;
      latitude = "52.37";
      longitude = "4.9";
    };
    
    physlock.enable = true;

    printing = {
      enable = true;
      drivers = [ pkgs.hplip ];
    };

    upower.enable = true;
    avahi = {
      enable = true;
      nssmdns = true;
    };

    geoclue2.enable = true;

    keybase.enable = true;
    kbfs.enable = true;

    chrony = {
      enable = true;
      servers = [];
      initstepslew.enabled = false;
      extraConfig = ''
        pool nl.pool.ntp.org iburst
        initstepslew 1000 0.nl.pool.ntp.org 1.nl.pool.ntp.org 2.nl.pool.ntp.org 3.nl.pool.ntp.org
        rtcfile /var/lib/chrony/chrony.rtc
      '';
    };
  };

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

  security.wrappers.physlock.source = "${pkgs.physlock}/bin/physlock";

  programs.adb.enable = true;

}
