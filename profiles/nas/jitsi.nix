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

    interfaceConfig = rec {
      SHOW_JITSI_WATERMARK = false;
      SHOW_WATERMARK_FOR_GUESTS = false;
      PROVIDER_NAME = "Arda Xi";
      APP_NAME = "${PROVIDER_NAME} Meet";
      NATIVE_APP_NAME = APP_NAME;
    };

  };

  services.nginx.virtualHosts.${services.jitsi-meet.hostName} = {
    forceSSL = true;
    enableACME = true;
  };
}
