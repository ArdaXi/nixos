{ pkgs, ... }:

let
  host = "freshrss.street.ardaxi.com";
in
{
  services.freshrss = {
    enable = true;
    virtualHost = host;
    baseUrl = "https://${host}";
    passwordFile = "/var/secrets/freshrss";
  };
}
