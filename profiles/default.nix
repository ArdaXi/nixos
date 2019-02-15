{ config, pkgs, lib, ... }:

{
  imports = [
    ../programs/tmux.nix
  ];

  nix.package = pkgs.nixUnstable;
  nixpkgs = {
    config = {
      allowUnfree = true;
      android_sdk.accept_license = true;
    };
    overlays = (import ../overlays);
  };

  hardware.enableAllFirmware = true;

  time.timeZone = "Europe/Amsterdam";

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC9L+dgqEWlz1HCAFvOo2WMcxXUCVZjEENrSCHEHdGKx ardaxi@hiro"
    ];
  };
  users.extraGroups.ardaxi.gid = 1000;

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
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
  ];

  environment.extraInit = "export XDG_CONFIG_DIRS=/etc/xdg:$XDG_CONFIG_DIRS";
}
