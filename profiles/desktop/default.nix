{ config, lib, pkgs, ... }:

{
  imports = [
#    ./i3
    ./sway
    ./alacritty.nix
    ./encryption.nix
    ./wireguard-systemd.nix
    ./chromium.nix
    ./multimedia.nix
    ./bluetooth.nix
    ./network.nix
    ./udisks.nix
    ./project.nix
    ./dunst.nix
  ];

  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages or pkgs.linuxPackages_5_12;

  services.syncthing = {
    overrideFolders = false;
    overrideDevices = false;
  };

  services.physlock = {
    enable = true;
    allowAnyUser = true;
  };

  services.udev.packages = [ pkgs.qflipper ];

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
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
    fwupd.enable = true;
    pipewire.enable = true;
  };

  # For flatpak
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  environment.systemPackages = with pkgs; [
    # Development
    direnv gitAndTools.pass-git-helper gist rustup gcc exercism nodejs terraform-lsp
    qflipper
    # 3D
    solvespace prusa-slicer
    # LaTeX
    evince lyx (texlive.combine { inherit (texlive)
      scheme-basic babel-dutch hyphen-dutch invoice fp collection-latexrecommended xetex
      relsize collection-fontsrecommended draftwatermark everypage qrcode geometry tex4ht ec
      comment; })
    # Misc CLI
    taskwarrior fortune ledger usbutils pciutils acpi slock scrot xdotool nethack
    mosquitto xorg.xf86inputsynaptics
    # Misc graphical
    alacritty arandr dmenu fahclient calibre gnome-firmware-updater
    winbox
    (writeShellScriptBin "anki" ''
      export ANKI_WAYLAND=1
      exec ${pkgs.anki-bin}/bin/anki
    '')
    # Big stuff
    libreoffice-fresh signal-desktop steam
  ];

  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "sway";
  };

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    enableDefaultFonts = true;
    fonts = with pkgs; [
      source-code-pro vistafonts corefonts nerdfonts
      cantarell-fonts
    ];
  };

  programs.dconf.enable = true;
  programs.nix-ld.enable = true;
}
