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
{
  location = {
    latitude = 52.37;
    longitude = 4.9;
  };

  environment.systemPackages = with mypkgs; [
    networkmanagerapplet
#    (networkmanagerapplet.override { withGnome = false; })
    mpv
    alacritty taskwarrior fortune arandr lyx ledger
    source-code-pro usbutils pciutils gnupg acpi dmenu
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
    nodejs # for coc.nvim
    terraform-lsp # also for coc.nvim
    pavucontrol
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

    blueman.enable = true;

    redshift.enable = true;
    
    physlock.enable = true;

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
      extraModules = [ pkgs.pulseaudio-modules-bt ];
      extraConfig = ''
        load-module module-switch-on-connect
        load-module module-bluetooth-policy auto_switch=2
      '';
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
