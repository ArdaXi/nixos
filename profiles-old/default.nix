{ config, pkgs, lib, ... }:

{
  nix = {
    package = pkgs.nixUnstable;
    binaryCachePublicKeys = [ "street.ardaxi.com-1:A1P6oGDAlLPtBbscHNTzBM6DpMHGpqLNwXUgmOtNegg=" ];
    binaryCaches = [ https://cache.nixos.org/ http://nix-cache.street.ardaxi.com/ ];
    extraOptions = ''
      fallback = true
      experimental-features = nix-command flakes
    '';
  };
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
      android_sdk.accept_license = true;
      permittedInsecurePackages = [
         "openssl-1.0.2u"
      ];
# Not happy about this but it won't eval otherwise, despite not using it.
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

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = lib.mkForce "no";
  };

  environment.extraInit = "export XDG_CONFIG_DIRS=/etc/xdg:$XDG_CONFIG_DIRS";
}
