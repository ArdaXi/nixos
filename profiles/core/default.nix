{ config, lib, pkgs, ... }:

{
  imports = [ ./tmux.nix ];

  environment = {
    systemPackages = with pkgs; [
      wget unzip file vim neovim mosh psmisc binutils git screen fzf lsof htop ripgrep
      aspellDicts.en aspellDicts.nl kakoune jq tarsnap bat htop nox dnsutils
    ];
    extraInit = "export XDG_CONFIG_DIRS=/etc/xdg:$XDG_CONFIG_DIRS";
  };

  nix = {
    package = pkgs.nixFlakes;
    binaryCachePublicKeys = [ "street.ardaxi.com-1:A1P6oGDAlLPtBbscHNTzBM6DpMHGpqLNwXUgmOtNegg=" ];
    #binaryCaches = lib.mkIf (config.networking.hostName != "cic")
    #  [ "https://cache.nixos.org/" "http://nix-cache.street.ardaxi.com/" ];
    extraOptions = lib.mkForce ''
      fallback = true
      experimental-features = nix-command flakes ca-references
    '';
    autoOptimiseStore = true;
    optimise.automatic = true;
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
