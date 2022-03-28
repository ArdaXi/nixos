{ config, lib, pkgs, ... }:

{
  imports = [ 
    ./tmux.nix
    ./security.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      wget unzip file vim neovim mosh psmisc binutils git screen fzf lsof htop ripgrep
      aspellDicts.en aspellDicts.nl kakoune jq tarsnap bat htop nox dnsutils starship
      pv innernet
    ];
    extraInit = "export XDG_CONFIG_DIRS=/etc/xdg:$XDG_CONFIG_DIRS";
  };

  networking.wireguard.enable = true;

  nix = {
    package = lib.mkDefault pkgs.nixFlakes;
    binaryCachePublicKeys = [ "street.ardaxi.com-1:A1P6oGDAlLPtBbscHNTzBM6DpMHGpqLNwXUgmOtNegg=" ];
    binaryCaches = lib.mkIf (config.networking.hostName != "cic")
      [ "https://cache.nixos.org/" "http://nix-cache.street.ardaxi.com/" ];
    extraOptions = ''
      fallback = true
      experimental-features = nix-command flakes
    '';
    autoOptimiseStore = true;
    useSandbox = true;
    allowedUsers = [ "@wheel" ];
    trustedUsers = [ "root" "@wheel" ];
    systemFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
    android_sdk.accept_license = true;
    permittedInsecurePackages = [
      "openssl-1.0.2u"
      "python2.7-Pillow-6.2.2"
    ];
  };

  hardware.enableAllFirmware = true;
  time.timeZone = "Europe/Amsterdam";

  console = {
    keyMap = "us";
    font = "Lat2-Terminus16";
  };

  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = lib.mkForce "no";
  };
}
