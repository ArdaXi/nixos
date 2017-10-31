{ config, pkgs, lib, ... }:

{
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    overlays = (import ../overlays);
  };

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
    nix-repl
    silver-searcher
    mosh
    psmisc
    binutils
    (git.override { svnSupport = true; })
    gitAndTools.gitflow
    screen
    python27Packages.magic-wormhole
  ];
}
