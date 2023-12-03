{ config, lib, ... }:

{
  services.nginx = {
    enable = true;
    statusPage = true;
    recommendedProxySettings = lib.mkForce false;
    commonHttpConfig = ''
      proxy_cache_path /var/cache/nginx/authentication keys_zone=authentication:10m levels=1:2 inactive=3s;
      proxy_buffers 4 256k;
      proxy_buffer_size 128k;
    '';
    virtualHosts = let
      proxyConfig = ''
        proxy_ssl_verify   off;
        proxy_set_header   Host              $host;
        proxy_set_header   X-Real-IP         $remote_addr;
        proxy_set_header   X-Forward-For     $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
        proxy_set_header   Upgrade           $http_upgrade;
        proxy_set_header   Connection        $connection_upgrade;

        proxy_http_version 1.1;
      '';
      allow = ''
        allow 127.0.0.1;
        allow ::1;
        allow 192.168.178.0/24;
        allow 45.80.170.80/29;
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
          proxyPass = "http://127.0.0.1:${toString config.services.home-assistant.config.http.server_port}/";
          extraConfig = proxyConfig + ''
            proxy_set_header Connection "upgrade";
          '';
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
        locations = {
          "/oauth2/" = lib.mkIf config.services.oauth2_proxy.enable {
            proxyPass = config.services.oauth2_proxy.httpAddress;
            extraConfig = proxyConfig + ''
              proxy_set_header X-Scheme $scheme;
              proxy_set_header X-Auth-Request-Redirect $scheme://$host$request_uri;
            '';
          };
          "/oauth2/auth" = lib.mkIf config.services.oauth2_proxy.enable {
            proxyPass = config.services.oauth2_proxy.httpAddress;
            extraConfig = proxyConfig + ''
              proxy_set_header X-Scheme       $scheme;
              proxy_set_header Content-Length "";
              proxy_pass_request_body         off;

              proxy_cache          authentication;
              proxy_cache_valid    202 401 3s;
              proxy_cache_lock     on;
              proxy_ignore_headers Set-Cookie;

              proxy_cache_key $cookie__oauth2_proxy$cookie__oauth2_proxy_0$cookie__oauth2_proxy_1;
            '';
          };
          "/" = {
            proxyPass = "http://unix:${config.services.grafana.settings.server.socket}:/";
            extraConfig = proxyConfig + ''
              auth_request /oauth2/auth;
              error_page 401 = /oauth2/sign_in;

              auth_request_set $email $upstream_http_x_auth_request_email;
              proxy_set_header X-Email $email;

              auth_request_set $auth_cookie $upstream_http_set_cookie;
              add_header Set-Cookie $auth_cookie;
            '';
          };
        };
      };
      "auth.street.ardaxi.com" = lib.mkIf config.services.oauth2_proxy.enable {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/oauth2/" = {
            proxyPass = config.services.oauth2_proxy.httpAddress;
            extraConfig = proxyConfig + ''
              proxy_set_header X-Scheme $scheme;
              proxy_set_header X-Auth-Request-Redirect $scheme://$host$request_uri;

              proxy_buffer_size       128k;
              proxy_buffers           4 256k;
              proxy_busy_buffers_size 256k;
            '';
          };
          "/oauth2/auth" = {
            proxyPass = config.services.oauth2_proxy.httpAddress;
            extraConfig = proxyConfig + ''
              proxy_set_header        X-Scheme $scheme;
              proxy_set_header        Content-Length "";
              proxy_pass_request_body off;

              proxy_cache          authentication;
              proxy_cache_valid    202 401 3s;
              proxy_cache_lock     on;
              proxy_ignore_headers Set-Cookie;

              proxy_cache_key $cookie__oauth2_proxy$cookie__oauth2_proxy_0$cookie__oauth2_proxy_1;
             '';
          };
        };
      };
      ${config.services.tt-rss.virtualHost} = lib.mkIf config.services.tt-rss.enable {
        enableACME = true;
        forceSSL = true;
        extraConfig = proxyConfig;
      };
      ${config.services.zoneminder.hostname} =
      lib.mkIf config.services.zoneminder.enable {
        enableACME = true;
        forceSSL = true;
        extraConfig = proxyConfig + extraAllow;
        default = lib.mkForce false;
        listen = lib.mkForce [
          { addr = "0.0.0.0"; port = 443; ssl = true; }
          { addr = "[::0]"; port = 443; ssl = true; }
        ];
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
          proxyPass = "http://127.0.0.1:${toString config.services.keycloak.settings.http-port}";
          extraConfig = proxyConfig + ''
            proxy_buffers     4 256k;
            proxy_buffer_size 128k;
          '' + allow;
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
          "/radarr/" = lib.mkIf config.services.radarr.enable {
            proxyPass = "http://127.0.0.1:7878";
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
