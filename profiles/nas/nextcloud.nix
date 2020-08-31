{ config, pkgs, lib, ... }:

rec {
  services.nextcloud = {
    enable = true;

    home = "/var/lib/nextcloud";

    config = {
      dbtype = "pgsql";
      dbhost = "127.0.0.1";
      adminuser = "admin";
      adminpassFile = "${services.nextcloud.home}/admin.pass";
    };

    hostName = "nextcloud.street.ardaxi.com";
    https = true;
    maxUploadSize = "10G";

    package = pkgs.nextcloud18;
  };
}
