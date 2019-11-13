{ config, options, pkgs, lib, ... }:

let
  mypkgs = pkgs // import ../pkgs;
in
{
  imports = [
    ../programs/i3
    ../programs/alacritty.nix
    ../programs/yubikey.nix
    ../programs/wireguard.nix
    ../programs/qemu.nix
  ];

  location = {
    latitude = 52.37;
    longitude = 4.9;
  };

#  boot.kernelPackages = pkgs.linuxPackages_5_1;

  environment.systemPackages = with mypkgs; [
    networkmanagerapplet
#    (networkmanagerapplet.override { withGnome = false; })
    (mpv.override { vaapiSupport = true; })
    alacritty taskwarrior fortune arandr lyx ledger
    source-code-pro lighttable usbutils pciutils gnupg acpi dmenu
    xorg.xf86inputsynaptics xdotool slock gcc scrot
    glib_networking pass
    browserpass nfsUtils keybase pinentry_qt
#python3Packages.neovim
    alsaUtils keybase-gui firefox-bin
    isync notmuch msmtp astroid afew libnotify
    google-chrome gist rustup tomb exercism
    direnv gist whois mtr
    (texlive.combine {
      inherit (texlive) scheme-basic babel-dutch hyphen-dutch invoice fp collection-latexrecommended xetex relsize collection-fontsrecommended draftwatermark everypage qrcode geometry;
# collectionhtmlxml xetex-def
    })
    slic3r-prusa3d solvespace prusa-slicer
    gitAndTools.pass-git-helper
    nethack
    evince
  ];

  networking = {
    firewall = {
      allowedTCPPorts = [ 10999 8000 80 ];
      allowedUDPPorts = [ 10999 67 ];
      trustedInterfaces = [ "wlanzap0" ];
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

    interfaces."wlanzap0" = {
      mtu = 1420;
      ipv4.addresses = [ { address = "192.168.177.129"; prefixLength = 25; } ];
    };
  };

  systemd.services.hostapd.requiredBy = lib.mkForce [];

  boot.kernel.sysctl = { "net.ipv4.ip_forward" = 1; };

  services = {
    dnsmasq = {
      enable = true;
      servers = [ "8.8.4.4" "8.8.8.8" "2001:4860:4860::8844" "2001:4860:4860::8844" ]; # Google
      extraConfig = ''
        interface=wlanzap0
        bind-interfaces
        dhcp-option=3,192.168.177.129
        dhcp-option=6,8.8.4.4,8.8.8.8
        dhcp-option=26,1420
        dhcp-range=192.168.177.130,192.168.177.254,5m
      '';
    };

    hostapd = {
      enable = true;
      interface = "wlanzap0";
      channel = 1;
      ssid = "hiro";
      wpa = false; # Workaround for weirdly written hostapd module
      extraConfig = ''
        wpa=2
        wpa_psk_file=/var/wpa_psk
        hw_mode=g
        ieee80211n=1

        wpa_key_mgmt=WPA-PSK
        rsn_pairwise=CCMP
      '';
    };

    redshift.enable = true;
    
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
      vistafonts
      corefonts
    ];
  };

  hardware = {
    pulseaudio = { 
      enable = true;
#      support32Bit = true;
    };
#    opengl.driSupport32Bit = true;
    bluetooth.enable = true;
  };

  nixpkgs.config = {
    packageOverrides = pkgs: {
      bluez = pkgs.bluez5;
    };
  };

  security.wrappers.physlock.source = "${pkgs.physlock}/bin/physlock";

  programs = {
    adb.enable = true;

    gnupg.agent = {
      enable = true;
      enableBrowserSocket = true;
      enableExtraSocket = true;
      enableSSHSupport = true;
    };
  };

  nix = {
    buildMachines = [
      { hostName = "street.ardaxi.com";
        systems = [ "builtin" "x86_64-linux" "i686-linux" ];
        supportedFeatures = [ "kvm" "nixos-test" "big-parallel" "benchmark" "local" ];
        maxJobs = 6;
        sshUser = "nixbuild";
        sshKey = "/root/.ssh/id_buildfarm";
      }
    ];
    distributedBuilds = false;
    extraOptions = ''
      builders-use-substitutes = true
    '';
  };
}
