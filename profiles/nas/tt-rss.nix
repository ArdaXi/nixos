{ ... }:

let
  host = "rss.street.ardaxi.com";
in
{
  services.tt-rss = {
    enable = true;
    pubSubHubbub.enable = true;
    virtualHost = host;
    selfUrlPath = "https://${host}";
    extraConfig = "putenv('TTRSS_SESSION_COOKIE_LIFETIME=2147483647');";
  };
}
