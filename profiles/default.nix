{ config, pkgs, lib, ... }:

{
  imports = [
    ../programs/tmux.nix
  ];

  nix = {
    package = pkgs.nixUnstable;
    binaryCachePublicKeys = [ "street.ardaxi.com-1:A1P6oGDAlLPtBbscHNTzBM6DpMHGpqLNwXUgmOtNegg=" ];
    binaryCaches = [ https://cache.nixos.org/ http://nix-cache.street.ardaxi.com/ ];
    extraOptions = "fallback = true";
  };
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
      android_sdk.accept_license = true;
    };
    overlays = (import ../overlays);
  };

  hardware.enableAllFirmware = true;

  time.timeZone = "Europe/Amsterdam";

  console = {
    keyMap = "us";
    font = "Lat2-Terminus16";
  };

  i18n.defaultLocale = "en_US.UTF-8";

  users.extraUsers.ardaxi = {
    name = "ardaxi";
    group = "ardaxi";
    extraGroups = [
      "users"
      "wheel"
      "networkmanager"
      "audio"
      "adbusers"
    ];
    uid = 1000;
    home = "/home/ardaxi";
    createHome = true;
    shell = "/run/current-system/sw/bin/zsh";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCnEDvMXrD7Hh3iQC42v2RlVs386cs3f2Z9UfTwblK8Qj65KqMoIqbNw6X0c0hW0dwYArAdQmxJBhynS+ajoNs0I+WY+SLT1DHPx/KejepzlQEYpmlSXp7bTc4B68iTy3nqTbmbxyHDHAfBeEoMDctGzuqr1wHTBM3oxaWn37OxoNQOux/RnjPWLQpv7UmUniUimrn1f6aEX93SO7GqVzqPzG3FnwcAtEaTw2tWeE349T8eG+Qf+17w/3YRwzRll9G8FKEcInnnpMSXEghkW6wZP99WeNDuOTPK9EYeb/oEOEZEvk8DXFzbDNSxBG5F2riRXL2JW1pQxYPemmiGIlnehxm1qLZ465v/LvdKS3ice6WD8s52cQaPUQiFvRxfrnfxxLxKb3mxmZJJtenIrvvDXVgmmJ+31qk0x8O8ZaaZZUI6XKw3HyfqXOgjrj1T+ppB2wNOIrKysKVbb26fviBwGGFOq9Kp/qyNcM1hMh8U7KWzUnzb77Yw1x3AzYwyf6y9i49XuxYJzrud+5yJbj9rtWby748grENM6KMVjPv8D//3MFmLKeHuohR4Ft+yBTWCbYrZU8dV5KBVfK8he2lDHG9gDCdGKjXn9jngFWBdHaXixtMMQHC0dZmycATnnR5acoN52xzj/K0sVod3jqrpT/J+SxVHbw2OpruVx6Qs+Q== openpgp:0xADB81AB8" #5C
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC9L+dgqEWlz1HCAFvOo2WMcxXUCVZjEENrSCHEHdGKx ardaxi@hiro"
    ];
  };
  users.extraGroups.ardaxi.gid = 1000;

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = lib.mkForce "no";
  };

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    unzip
    file
    vim
    neovim
    silver-searcher
    mosh
    psmisc
    binutils
    git
    gitAndTools.gitflow
    screen
    fzf
    lsof
    aspellDicts.en
    aspellDicts.nl
    kakoune
    jq
    tarsnap
  ];

  environment.extraInit = "export XDG_CONFIG_DIRS=/etc/xdg:$XDG_CONFIG_DIRS";
}
