{ config, lib, pkgs, ... }:

{
  imports = [ 
    ./tmux.nix
    ./security.nix
    ./syncthing.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      wget unzip file vim neovim mosh psmisc binutils git screen fzf lsof htop ripgrep
      aspellDicts.en aspellDicts.nl kakoune jq tarsnap bat htop nox dnsutils starship
      pv innernet waypipe
    ];
    extraInit = "export XDG_CONFIG_DIRS=/etc/xdg:$XDG_CONFIG_DIRS";
  };

  networking.wireguard.enable = true;

  nix = {
    package = lib.mkDefault pkgs.nixVersions.stable;
    extraOptions = ''
      fallback = true
      experimental-features = nix-command flakes
      allow-import-from-derivation = true
    '';
    settings = {
      substituters = lib.mkIf (config.networking.hostName != "cic") [
        "https://cache.nixos.org/" "http://nix-cache.street.ardaxi.com/"
      ];
      trusted-public-keys = [
        "street.ardaxi.com-1:A1P6oGDAlLPtBbscHNTzBM6DpMHGpqLNwXUgmOtNegg="
      ];
      sandbox = true;
      allowed-users = [ "@wheel" ];
      trusted-users = [ "root" "@wheel" ];
      system-features = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      auto-optimise-store = true;
    };
  };

#  nixpkgs.config = {
#    allowUnfree = true;
#    allowBroken = true;
#    android_sdk.accept_license = true;
#    permittedInsecurePackages = [
#      "openssl-1.0.2u"
#      "python2.7-Pillow-6.2.2"
#    ];
#  };

  hardware.enableRedistributableFirmware = true;
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
