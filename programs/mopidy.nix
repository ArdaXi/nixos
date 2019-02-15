{ config, pkgs, ... }:

{
  services.mopidy = {
    enable = true;
    extensionPackages = with pkgs; [
      mopidy-spotify mopidy-spotify-tunigo mopidy-mopify mopidy-iris
    ];
    extraConfigFiles = [
      "/home/ardaxi/.config/mopidy/mopidy.conf"
    ];
  };
}
