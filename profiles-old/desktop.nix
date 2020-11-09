{ config, options, pkgs, lib, ... }:

{
  imports = [
    ../programs/i3
    ../programs/alacritty.nix
    ../programs/yubikey.nix
    ../programs/wireguard.nix
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
#{ # ipfs
#  services.ipfs = {
#    enable = true;
#    autoMount = true;
#  };
#
#  networking.firewall.allowedTCPPorts = [ 4001 ];
#}
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
{ # Multimedia
  hardware.pulseaudio = {
    package = pkgs.pulseaudioFull;
    enable = true;
    support32Bit = true;
  };

  environment.systemPackages = with pkgs; [
    mpv alsaUtils pavucontrol
  ];
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
  services.lorri.enable = true;

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
        everypage qrcode geometry tex4ht ec comment;
        # collectionhtmlxml xetex-def
    })
  ];
}
{ # Encryption (GnuPG etc)
  programs.gnupg.agent = {
    enable = true;
    enableBrowserSocket = true;
    enableExtraSocket = true;
    enableSSHSupport = true;
  };

  environment.systemPackages = with pkgs; [
    gnupg pass browserpass pinentry_qt tomb
  ];
}
#{ # Email
#  environment.systemPackages = with pkgs; [
#    isync notmuch msmtp astroid afew libnotify
#  ];
#}
{ # Misc cli utils
  programs.adb.enable = true;

  environment.systemPackages = with pkgs; [
    taskwarrior fortune ledger usbutils pciutils acpi slock scrot nfsUtils xdotool
    xorg.xf86inputsynaptics
    nethack mosquitto
  ];
}
{ # Misc graphical
  services.redshift.enable = true;
  environment.systemPackages = with pkgs; [
    alacritty arandr dmenu fahclient calibre
  ];
}
{ # Fonts
  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      source-code-pro
      vistafonts
      corefonts
    ];
  };

#  environment.systemPackages = with pkgs; [
#    source-code-pro # TODO: Needed?
#  ];
}
{ # Networking
  services.resolved = {
    enable = true;
    dnssec = "true";
    fallbackDns = [
      # XS4ALL
      "194.109.6.66"
      "194.109.9.99"
      "194.109.104.104"
      "2001:888:0:6::66"
      "2001:888:0:9::99"

      # Quad9
      "9.9.9.9"
      "149.112.112.112"
      "2620:fe::fe"
      "2620:fe::9"

      # OpenDNS
      "208.67.222.222"
      "208.67.220.220"
    ];
  };

  networking = {
    firewall = {
      logRefusedConnections = false;
      extraCommands = ''
        iptables -A nixos-fw -s 192.168.178.0/24 -j nixos-fw-accept -i enp0s20f0u4u1
      ''; # Open requests from local (trusted) network
    };

    networkmanager = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    google-chrome firefox-bin
    networkmanagerapplet
#    glib_networking # TODO: Still needed?
    whois mtr
  ];
}
{ # flatpak
  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };
}
{ # Hardware
  environment.systemPackages = with pkgs; [
    gnome-firmware-updater
  ];
  services = {
    fwupd.enable = true;

    printing = {
      enable = true;
      drivers = [ pkgs.hplip pkgs.epson-escpr ];
    };

    upower.enable = true;
  };

  hardware.opengl.driSupport32Bit = true;
}
{
  services = {
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
  };

  nix = {
#    buildMachines = [
#      { hostName = "street.ardaxi.com";
#        systems = [ "builtin" "x86_64-linux" "i686-linux" ];
#        supportedFeatures = [ "kvm" "nixos-test" "big-parallel" "benchmark" "local" ];
#        maxJobs = 6;
#        sshUser = "nixbuild";
#        sshKey = "/root/.ssh/id_buildfarm";
#      }
#    ];
#    distributedBuilds = true;
#    extraOptions = ''
#      builders-use-substitutes = true
#    '';
  };
}
];
}
