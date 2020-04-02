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
    videobridge = {
      openFirewall = true;
      config = {
        "org.jitsi.videobridge.rest.private.jetty.port" = "8888";
        "org.jitsi.videobridge.rest.private.jetty.host" = "localhost";
      };
    };

#    config = {
#      hosts = {
#        anonymousdomain = "guest.${services.jitsi-meet.hostName}";
#      };
#    };
#    jicofo.config = {
#      "org.jitsi.jicofo.auth.URL" = "XMPP:${services.jitsi-meet.hostName}";
#    };
  };

#  services.prosody.virtualHosts = {
#    "guest.${services.jitsi-meet.hostName}" = {
#      enabled = true;
#      domain = "guest.${services.jitsi-meet.hostName}";
#      extraConfig = ''
#        authentication = "anonymous"
#        c2s_require_encryption = false
#      '';
#    };
#    "${services.jitsi-meet.hostName}".extraConfig = lib.mkForce ''
#      authentication = "internal_plain"
#      admins = { "focus@auth.${services.jitsi-meet.hostName}" }
#
#      Component "conference.${services.jitsi-meet.hostName}" "muc"
#        storage = "memory"
#
#      Component "jitsi-videobridge.${services.jitsi-meet.hostName}"
#        component_secret = os.getenv("VIDEOBRIDGE_COMPONENT_SECRET")
#    '';
#  };

  services.nginx.virtualHosts.${services.jitsi-meet.hostName} = {
    forceSSL = true;
    enableACME = true;
  };
}
