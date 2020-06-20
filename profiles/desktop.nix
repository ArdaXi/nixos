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
    ../programs/chromium.nix
    ../modules/tiddlywiki.nix
  ];
  config = lib.mkMerge [
{
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
{
  services.openssh.openFirewall = false;
}
{ # ipfs
  services.ipfs = {
    enable = true;
    autoMount = true;
  };

  networking.firewall.allowedTCPPorts = [ 4001 ];
}
{ # location stuff
  location = {
    latitude = 52.37;
    longitude = 4.9;
  };

  services.geoclue2.enable = true;
}
{ # physlock
  security.wrappers.physlock.source = "${pkgs.physlock}/bin/physlock";
  services.physlock.enable = true;
}
{ # keybase
  environment.systemPackages = with pkgs; [ keybase keybase-gui ];
  services = {
    keybase.enable = true;
    kbfs.enable = true;
  };
}
{ # bluetooth
  services.blueman.enable = true;
  hardware = {
    bluetooth.enable = true;
    pulseaudio = {
      extraModules = [ pkgs.pulseaudio-modules-bt ];
      extraConfig = ''
        load-module module-switch-on-connect
        load-module module-bluetooth-policy auto_switch=2
      '';
    };
  };

  nixpkgs.config.packageOverides = pkgs : {
    bluez = pkgs.bluez5;
  };
}
{ # 3D printing
  environment.systemPackages = with pkgs; [
    slic3r-prusa3d solvespace prusa-slicer
  ];
}
{ # Software development
  environment.systemPackages = with pkgs; [
    direnv gitAndTools.pass-git-helper gist
    rustup gcc exercism
    nodejs terraform-lsp # coc.nvim
  ];
}
{ # Documents (LaTeX etc)
  environment.systemPackages = with pkgs; [
    evince lyx
    (texlive.combine {
      inherit (texlive) scheme-basic babel-dutch hyphen-dutch invoice fp
        collection-latexrecommended xetex relsize collection-fontsrecommended draftwatermark
        everypage qrcode geometry;
        # collectionhtmlxml xetex-def
    })
  ];
}
{ # Networking
  environment.systemPackages = with pkgs; [
    google-chrome firefox-bin
    networkmanagerapplet
    glib_networking # TODO: Still needed?
    whois mtr
  ];
}
{ # Encryption (GnuPG etc)
  environment.systemPackages = with pkgs; [
    gnupg pass browserpass pinentry_qt tomb
  ];
}
{ # Multimedia
  environment.systemPackages = with pkgs; [
    mpv alsaUtils pavucontrol
  ];
}
{ # Email
  environment.systemPackages = with pkgs; [
    isync notmuch msmtp astroid afew libnotify
  ];
}
{ # Misc cli utils
  environment.systemPackages = with pkgs; [
    taskwarrior fortune ledger usbutils pciutils acpi slock scrot nfsUtils xdotool
    xorg.xf86inputsynaptics
  ];
}
{
  environment.systemPackages = with mypkgs; [
    alacritty arandr
    source-code-pro dmenu
    nethack
    fahclient
  ];

  networking = {
    firewall = {
      allowedTCPPorts = [ 10999 8000 80 ];
      allowedUDPPorts = [ 10999 67 ];
      extraCommands = ''
        iptables -A nixos-fw -s 192.168.178.0/24 -j nixos-fw-accept -i enp0s20f0u4u1
      '';
    };

    extraHosts = ''
      192.168.178.2  tahoe.street.ardaxi.com
      192.168.178.2  sickrage.local.ardaxi.com
      192.168.178.2  sabnzbd.local.ardaxi.com
      192.168.178.2  local.ardaxi.com
    '';

    networkmanager = {
      enable = true;
    };
  };

  services = {
    lorri.enable = true;

    redshift.enable = true;
    
    fwupd.enable = true;

    printing = {
      enable = true;
      drivers = [ pkgs.hplip pkgs.epson-escpr ];
    };

    upower.enable = true;
    avahi = {
      enable = true;
      nssmdns = true;
    };

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

    tiddlywiki-user = {
      enable = true;

      listenOptions = {
        port = 8081;
      };
    };

    flatpak.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
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
      package = pkgs.pulseaudioFull;
      enable = true;
      support32Bit = true;
    };
    opengl.driSupport32Bit = true;
  };

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
];
}
