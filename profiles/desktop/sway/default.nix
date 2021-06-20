{ config, pkgs, ... }:

rec {
  environment.etc."sway/config".source = (pkgs.substituteAll {
    name = "sway-config";
    src = ./config;
    inherit (pkgs) alacritty zsh tmux dmenu fzf findutils;
    i3statusRust = pkgs.i3status-rust;
    i3statusConfig = ./i3status.toml;
  }).outPath;

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "chrome" ''
      exec ${pkgs.google-chrome}/bin/google-chrome-stable --enable-features=UseOzonePlatform --ozone-platform=wayland
    '')
    (pkgs.writeShellScriptBin "signal" ''
      exec ${pkgs.signal-desktop}/bin/signal-desktop --enable-features=UseOzonePlatform --ozone-platform=wayland
    '')
  ];

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
      export XKB_DEFAULT_LAYOUT=us
      export XKB_DEFAULT_OPTIONS=compose:caps
      export GDK_DPI_SCALE=0.75

      ${pkgs.networkmanagerapplet}/bin/nm-applet &
      ${pkgs.xsettingsd}/bin/xsettingsd &
    '';
  };

  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "compose:caps";
    displayManager = {
      autoLogin = {
        enable = true;
        user = "ardaxi";
      };
      lightdm = {
        enable = true;
        greeter.enable = false;
      };
    };
    desktopManager.xterm.enable = false;

    displayManager.defaultSession = "sway";

    synaptics = {
      enable = true;
      tapButtons = false;
      twoFingerScroll = true;
      accelFactor = "0.03";
    };
  };

  fonts.fonts = [ pkgs.font-awesome_5 pkgs.powerline-fonts ];

  systemd.user.targets.sway-session = {
    description = "Sway compositor session";
    documentation = [ "man:systemd.special(7)" ];
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
  };
}
