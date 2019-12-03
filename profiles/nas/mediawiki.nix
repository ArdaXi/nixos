{ config, lib, pkgs, ... }:
{
  imports = [
    ./mediawiki-nginx.nix
  ];

  services.mediawiki = {
    enable = true;

    database = {
      type = "postgres";
      host = "127.0.0.1";
      port = 5432;
      user = "mediawiki";
      socket = null;
    };

    name = "Arda Xi";
  };

  services.httpd.enable = lib.mkForce false;
}
