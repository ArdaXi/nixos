{ config, lib, ... }:

{
  services.nginx = {
    enable = true;
    statusPage = true;
    virtualHosts = let
      proxyConfig = ''
        proxy_ssl_verify   off;
        proxy_set_header   Host              $host;
        proxy_set_header   X-Real-IP         $remote_addr;
        proxy_set_header   X-Forward-For     $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
        proxy_set_header   Upgrade           $http_upgrade;
        proxy_set_header   Connection        "upgrade";

        proxy_http_version 1.1;
      '';
      allow = ''
        allow 192.168.178.0/24;
        allow 2a10:3781:19df::/48;
        deny  all;
      '';
      extraAllow = "allow 192.168.179.0/24;" + allow;
    in {
      "_" = {
        default = true;
        addSSL = true;
        useACMEHost = "street.ardaxi.com";
        extraConfig = ''
          return 444;
        '';
      };
      "anki.street.ardaxi.com" = lib.mkIf config.services.ankisyncd.enable {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://unix:/run/ankisyncd/ankisyncd.sock:/";
          extraConfig = proxyConfig;
        };
      };
      "home.street.ardaxi.com" = lib.mkIf config.services.home-assistant.enable {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.home-assistant.port}/";
          extraConfig = proxyConfig;
        };
      };
      "hydra.street.ardaxi.com" = lib.mkIf config.services.hydra.enable {
        enableACME = true;
        addSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.hydra.port}";
          extraConfig = proxyConfig;
        };
      };
      "matrix.ardaxi.com" = lib.mkIf config.services.matrix-synapse.enable {
        enableACME = true;
        forceSSL = true;
        locations."/_matrix" = {
          proxyPass = "http://127.0.0.1:8008";
          extraConfig = "proxy_set_header X-Forwarded-For $remote_addr;";
        };
      };
      "nix-cache.street.ardaxi.com" = lib.mkIf config.services.nix-serve.enable {
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.nix-serve.port}";
        };
      };
      "unifi.street.ardaxi.com" = lib.mkIf config.services.unifi.enable {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "https://127.0.0.1:8443"; # seems hardcoded
          extraConfig = proxyConfig + allow;
        };
      };
      "grafana.street.ardaxi.com" = lib.mkIf config.services.grafana.enable {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://unix:${config.services.grafana.extraOptions.SERVER_SOCKET}:/";
          extraConfig = proxyConfig;
#          proxyPass = "http://127.0.0.1:${toString config.services.grafana.port}";
        };
      };
      "paper.ardaxi.com" = lib.mkIf config.services.paperless-ng.enable {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.paperless-ng.port}/";
          extraConfig = proxyConfig + extraAllow;
        };
      };
      "lang.ardaxi.com" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:9111";
          extraConfig = proxyConfig + extraAllow; #+ ''
          #  add_header "Access-Control-Allow-Origin" *;
          #'';
        };
      };
      "street.ardaxi.com" = {
        enableACME = true;
        forceSSL = true;
      };
      "ipfs.street.ardaxi.com" = lib.mkIf config.services.ipfs.enable {
        enableACME = true;
        addSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8181";
          extraConfig = proxyConfig + allow;
        };
      };
      "keycloak.ardaxi.com" = lib.mkIf config.services.keycloak.enable {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${config.services.keycloak.httpPort}";
          extraConfig = proxyConfig + allow;
        };
      };
      "local.street.ardaxi.com" = {
        enableACME = true;
        addSSL = true;
        locations = {
          "/" = {
            alias = "/var/lib/nginx/index/";
            index = "index.html";
            extraConfig = allow;
          };
          "/espfw/" = {
            alias = "/var/lib/espfw/";
            extraConfig = ''
              autoindex on;
              allow 192.168.179.0/24;
            '' + allow;
          };
          "/hydra/" = lib.mkIf config.services.hydra.enable {
            proxyPass = "http://127.0.0.1:${toString config.services.hydra.port}/";
            extraConfig = allow;
          };
          "/media/" = {
            alias = "/media/";
            extraConfig = ''
              allow 192.168.179.0/24;
              autoindex on;
            '' + allow;
          };
          "/sabnzbd/" = lib.mkIf config.services.sabnzbd.enable {
            proxyPass = "http://127.0.0.1:8081/"; # not declarative yet
            extraConfig = allow;
          };
          "/sickrage/" = lib.mkIf config.services.sickrage.enable {
            proxyPass = "http://127.0.0.1:8082";
            extraConfig = allow;
          };
          "/transmission/" = lib.mkIf config.services.transmission.enable {
            proxyPass = "http://127.0.0.1:${toString config.services.transmission.settings.rpc-port}";
            extraConfig = allow;
          };
          "/nzbget/" = lib.mkIf config.services.nzbget.enable {
            proxyPass = "http://127.0.0.1:8083";
            extraConfig = allow;
          };
          "/sonarr/" = lib.mkIf config.services.sonarr.enable {
            proxyPass = "http://127.0.0.1:8989";
            extraConfig = allow;
          };
        };
      };
    };
  };

  users.users."${config.services.nginx.user}".extraGroups = [
    # I know this will probably never change, but it's still hardcoded
    config.users.users."${config.systemd.services.grafana.serviceConfig.User}".group
  ];
}
