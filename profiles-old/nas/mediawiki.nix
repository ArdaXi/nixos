{ config, lib, pkgs, ... }:
{
  containers.mediawiki = {
    autoStart = true;

    bindMounts = {
      "/var/lib/mediawiki" = {
        isReadOnly = false;
        mountPoint = "/var/lib/mediawiki";
      };
    };

    privateNetwork = true;
    hostAddress = "10.4.4.1";
    localAddress = "10.4.4.2";

    config = { config, pkgs, ... }: {
      services.mediawiki = {
        enable = true;

        database.createLocally = true;

        virtualHost = {
          adminAddr = "admin@ardaxi.com";
          hostName = "wiki.street.ardaxi.com";
        };

        name = "Arda Xi";

        passwordFile = "/var/lib/mediawiki/password";

        extraConfig = ''
          # Needed because of reverse proxy
          $wgServer = "https://wiki.street.ardaxi.com";
        '';
      };
    };
  };
}
