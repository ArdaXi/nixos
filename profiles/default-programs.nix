{ config, pkgs, lib, ... }:

{
  imports = [
    ../programs/tmux.nix
  ];

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
    bat
    htop
    nox
    dnsutils
    htop
    ripgrep
  ];
}
