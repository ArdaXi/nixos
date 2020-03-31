{ config, pkgs, lib, ... }:

rec {
  imports = let
    nur-no-pkgs = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {};
  in [
    nur-no-pkgs.repos.otevrenamesta.modules.jitsi-meet
  ];

  services.jitsi-meet = {
    enable = true;
    hostName = "meet.ardaxi.com";
    videobridge.openFirewall = true;

# Later: https://github.com/jitsi/jicofo#secure-domain
#    config = {
#      hosts = {
#        anonymousdomain = "guest.${services.jitsi-meet.hostName}";
#      };
#    };
#    jicofo.config = {
#      "org.jitsi.jicofo.auth.URL" = "XMPP:${services.jitsi-meet.hostName}";
#    };
  };

  services.nginx.virtualHosts.${services.jitsi-meet.hostName} = {
    forceSSL = true;
    enableACME = true;
  };
}
