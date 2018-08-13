{ config, pkgs, ... }:

let
  mypkgs = pkgs // import ../pkgs;
  lockIfYubi = pkgs.writeScript "lockIfYubi" ''
    #!${pkgs.stdenv.shell}
    if ${pkgs.usbutils}/bin/lsusb | ${pkgs.gnugrep}/bin/grep -q Yubikey || ${pkgs.procps}/bin/pgrep physlock; then
      exit 0
    fi
    /run/wrappers/bin/physlock -d
  '';
in
{
  imports = [
    ./xserver-xmonad.nix
    ../programs/wikibase.nix
  ];

  environment.systemPackages = with mypkgs; [
    (networkmanagerapplet.override { withGnome = false; })
    (mpv.override { vaapiSupport = true; })
    alacritty taskwarrior fortune google-chrome arandr adobe-reader lyx ledger
    source-code-pro lighttable usbutils pciutils gnupg acpi steam dmenu
    xorg.xf86inputsynaptics xdotool slock rustracer gcc rustfmt tahoelafs scrot
    wineStaging winetricks taffybar glib_networking pass
    browserpass nfsUtils keybase pinentry_qt4 python3Packages.neovim
    alsaUtils android-studio keybase-gui riot-desktop firefox-beta-bin
    libu2f-host libreoffice
    (rustNightly.rustcWithSysroots {
      rustc = rustNightly.rustc {};
      sysroots = builtins.map rustNightly.rust-std [
        {}
        { system = "arm-linux-androideabi"; }
      ];
    })
    (rustNightly.cargo {})
    (texlive.combine {
      inherit (texlive) scheme-basic babel-dutch hyphen-dutch invoice fp collection-latexrecommended xetex relsize collection-fontsrecommended draftwatermark everypage;
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
      servers = [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ]; # Cloudflare
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

    udev.extraRules = ''
DRIVER=="snd_hda_intel", ATTR{power/control}="on"
SUBSYSTEM=="usb", ATTR{idVendor}=="1d50", ATTR{idProduct}=="cc15", MODE="0600", OWNER="ardaxi", GROUP="ardaxi"
SUBSYSTEM=="usb", ATTR{idVendor}=="1d50", ATTR{idProduct}=="6089", MODE="0600", OWNER="ardaxi", GROUP="ardaxi"
SUBSYSTEM=="usb", ATTR{idVendor}=="1050", ATTR{idProduct}=="0406", MODE="0600", OWNER="ardaxi", GROUP="ardaxi"
'';

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

    #YUBIKEY
    pcscd.enable = true;
  };

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      source-code-pro
    ];
  };

  hardware = {
    u2f.enable = true;
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

#  security.pam.services.sudo.u2f = {
#    enable = true;
#    options = "cue";
#  };

#  security.pam.services.polkit-1.u2f = {
#    enable = true;
#    options = "cue";
#  };

  programs.adb.enable = true;

  networking.wireguard.interfaces.wg0 = {
    ips = [ "192.168.179.2/24" "2001:985:5782:2::2/64" ];
    peers = [ {
      allowedIPs = [ "0.0.0.0/0" "::/0" ];
      endpoint = "vpn.street.ardaxi.com:51820";
      publicKey = "Ez5OhMCNwZ2aoe3xxUvhERPnweEoM+cWbVXU2+VgEh0=";
    } ];
    privateKeyFile = "/private/wg/privatekey";
    allowedIPsAsRoutes = false;
  };
}
