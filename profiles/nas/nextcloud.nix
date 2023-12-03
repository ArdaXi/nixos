{ pkgs, ... }:

{
  services = {
    nextcloud = {
      enable = true;
      enableBrokenCiphersForSSE = false;
      package = pkgs.nextcloud25;
      hostName = "cloud.ardaxi.com";
      https = true;
      config = {
        dbtype = "pgsql";
        dbuser = "nextcloud";
        dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
        dbname = "nextcloud";
        adminpassFile = "/var/secrets/nextcloud";
        adminuser = "root";
      };
    };

    nginx.virtualHosts."cloud.ardaxi.com" = {
      enableACME = true;
      forceSSL = true;
    };

    postgresql = {
      ensureDatabases = [ "nextcloud" ];
      ensureUsers = [{
        name = "nextcloud";
        ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
      }];
    };
  };

  systemd.services."nextcloud-setup" = {
    requires = ["postgresql.service"];
    after = ["postgresql.service"];
  };
}
