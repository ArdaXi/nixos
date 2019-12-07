{ config, lib, pkgs, ... }:
{
  imports = [
    ./mediawiki-module.nix
  ];

  services.mediawiki-nginx = {
    enable = true;

    hostName = "wiki.street.ardaxi.com";

    database = {
      type = "postgres";
      host = "127.0.0.1";
      port = 5432;
      user = "mediawiki";
      socket = null;
    };

    name = "Arda Xi";

    passwordFile = "/var/lib/passwords/mediawiki";
  };

}
