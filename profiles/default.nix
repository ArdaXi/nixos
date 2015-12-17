{ config, pkgs, ... }:

{
  time.timeZone = "Europe/Amsterdam";

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  services.openssh.enable = true;

  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    file
    vim
    nix-repl
    silver-searcher
    mosh
    (git.override { svnSupport = true; })
  ];
}
