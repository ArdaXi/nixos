{ config, pkgs, lib, ... }:

with lib;

let
  hostName = "meet.ardaxi.com";
  auth = false;
in
{
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

    config = mkIf auth {
      hosts.anonymousdomain = "guest.${hostName}";
      enableUserRolesBasedOnToken = true;
    };

    jicofo.config = mkIf auth {
      "org.jitsi.jicofo.auth.URL" = "XMPP:${hostName}";
    };

    interfaceConfig = rec {
      SHOW_JITSI_WATERMARK = false;
      SHOW_WATERMARK_FOR_GUESTS = false;
      PROVIDER_NAME = "Arda Xi";
      APP_NAME = "${PROVIDER_NAME} Meet";
      NATIVE_APP_NAME = APP_NAME;
    };

  };

  services.prosody.virtualHosts = mkIf auth {
    "${hostName}".extraConfig = ''
      authentication = "internal_plain"
      c2s_require_encryption = false
      admins = { "focus@auth.${hostName}" }
      Component "conference.${hostName}" "muc"
        storage = "memory"
      Component "jitsi-videobridge.${hostName}"
        component_secret = os.getenv("VIDEOBRIDGE_COMPONENT_SECRET")
    '';

    "guest.${hostName}" = {
      enabled = true;
      domain = "guest.${hostName}";
      extraConfig = ''
        authentication = "anonymous"
        c2s_require_encryption = false
      '';
    };
  };

  services.nginx.virtualHosts.${hostName} = let 
    aliases = [ "meet.arien.dev" "meet.xn--arin-npa.eu" ];
    regexPart = lib.replaceStrings ["."] ["\\."] (lib.concatStringsSep "|" aliases);
    aliasRegex = "^https://(${regexPart})$";
  in {
    forceSSL = true;
    enableACME = true;

    serverAliases = aliases;

    locations."/http-bind".extraConfig = ''
      if (''$http_origin ~ '${aliasRegex}') {
        add_header 'Access-Control-Allow-Origin' "''$http_origin" always;
        add_header 'Access-Control-Allow-Credentials' 'true' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'Accept,Authorization,Cache-Control,Content-Type,DNT,If-Modified-Since,Keep-Alive,Origin,User-Agent,X-Requested-With' always;
      }

      if (''$request_method = 'OPTIONS') {
        add_header 'Access-Control-Max-Age' 1728000;
        add_header 'Content-Type' 'text/plain charset=UTF-8';
        add_header 'Content-Length' 0;
        return 204;
      }
    '';
  };
}
