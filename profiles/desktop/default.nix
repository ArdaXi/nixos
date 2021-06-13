{ config, lib, pkgs, ... }:

{
  imports = [
    ./i3
#    ./sway
    ./alacritty.nix
    ./encryption.nix
#    ./wireguard-systemd.nix
    ./chromium.nix
    ./multimedia.nix
    ./bluetooth.nix
    ./network.nix
    ./udisks.nix
    ./project.nix
    ./dunst.nix
  ];

  # For zfs < 2.1.0
  boot.kernelPackages = pkgs.linuxPackages_5_11;

  services.physlock = {
    enable = true;
    allowAnyUser = true;
  };

  location = {
    latitude = 52.37;
    longitude = 4.9;
  };

  services = {
    redshift.enable = true;
    lorri.enable = true;
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
    flatpak.enable = true;
  };

  # For flatpak
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  environment.systemPackages = with pkgs; [
    # Development
    direnv gitAndTools.pass-git-helper gist rustup gcc exercism nodejs terraform-lsp
    # 3D
    slic3r-prusa3d solvespace prusa-slicer
    # LaTeX
    evince lyx (texlive.combine { inherit (texlive)
      scheme-basic babel-dutch hyphen-dutch invoice fp collection-latexrecommended xetex
      relsize collection-fontsrecommended draftwatermark everypage qrcode geometry tex4ht ec
      comment; })
    # Misc CLI
    taskwarrior fortune ledger usbutils pciutils acpi slock scrot nfsUtils xdotool nethack
    mosquitto xorg.xf86inputsynaptics
    # Misc graphical
    alacritty arandr dmenu fahclient calibre anki-bin
    # Big stuff
    libreoffice-fresh signal-desktop steam
  ];

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [ source-code-pro vistafonts corefonts nerdfonts ];
  };

  programs.dconf.enable = true;
}
