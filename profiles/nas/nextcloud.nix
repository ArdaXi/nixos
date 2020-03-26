{ config, pkgs, ... }:

rec {
  services.nextcloud = {
    enable = true;

    home = "/var/lib/nextcloud";

    config = {
      dbtype = "pgsql";
      dbhost = "127.0.0.1";
      adminuser = "admin";
      adminpassFile = "${services.nextcloud.home}/admin.pass";
    };

    hostName = "nextcloud.street.ardaxi.com";
    nginx.enable = false;
    https = true;
    maxUploadSize = "10G";
  };

  services.nginx.virtualHosts = {
    ${services.nextcloud.hostName} = {
      forceSSL = true;
      enableACME = true;
      root = pkgs.nextcloud18 or pkgs.nextcloud;
      locations = let
        allow = ''
          allow 192.168.178.0/24;
          allow 82.94.130.160/29;
          allow 2001:984:3f27::/48;
          deny all;
        '';
      in
      {
        "= /robots.txt" = {
          priority = 100;
          extraConfig = ''
            allow all;
          log_not_found off;
          access_log off;
          '' + allow;
        };
        "/" = {
          priority = 200;
          extraConfig = "rewrite ^ /index.php;" + allow;
        };
        "~ ^/store-apps" = {
          priority = 201;
          extraConfig = "root ${services.nextcloud.home};" + allow;
        };
        "= /.well-known/carddav" = {
          priority = 210;
          extraConfig = allow + "return 301 $scheme://$host/remote.php/dav;";
        };
        "= /.well-known/caldav" = {
          priority = 210;
          extraConfig = allow + "return 301 $scheme://$host/remote.php/dav;";
        };
        "~ ^\\/(?:build|tests|config|lib|3rdparty|templates|data)\\/" = {
          priority = 300;
          extraConfig = "deny all;";
        };
        "~ ^\\/(?:\\.|autotest|occ|issue|indie|db_|console)" = {
          priority = 300;
          extraConfig = "deny all;";
        };
        "~ ^\\/(?:index|remote|public|cron|core/ajax\\/update|status|ocs\\/v[12]|updater\\/.+|ocs-provider\\/.+|ocm-provider\\/.+)\\.php(?:$|\\/)" = {
          priority = 500;
          extraConfig = ''
            include ${config.services.nginx.package}/conf/fastcgi.conf;
          fastcgi_split_path_info ^(.+\.php)(\\/.*)$;
          try_files $fastcgi_script_name =404;
          fastcgi_param PATH_INFO $fastcgi_path_info;
          fastcgi_param HTTPS ${if services.nextcloud.https then "on" else "off"};
          fastcgi_param modHeadersAvailable true;
          fastcgi_param front_controller_active true;
          fastcgi_pass unix:${config.services.phpfpm.pools.nextcloud.socket};
          fastcgi_intercept_errors on;
          fastcgi_request_buffering off;
          fastcgi_read_timeout 120s;
          '' + allow;
        };
        "~ ^\\/(?:updater|ocs-provider|ocm-provider)(?:$|\\/)".extraConfig = ''
          try_files $uri/ =404;
        index index.php;
        '' + allow;
        "~ \\.(?:css|js|woff2?|svg|gif)$".extraConfig = ''
          try_files $uri /index.php$request_uri;
        add_header Cache-Control "public, max-age=15778463";
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        add_header X-Robots-Tag none;
        add_header X-Download-Options noopen;
        add_header X-Permitted-Cross-Domain-Policies none;
        add_header Referrer-Policy no-referrer;
        access_log off;
        '' + allow;
        "~ \\.(?:png|html|ttf|ico|jpg|jpeg)$".extraConfig = ''
          try_files $uri /index.php$request_uri;
        access_log off;
        '' + allow;
      };
      extraConfig = ''
        add_header X-Content-Type-Options nosniff;
      add_header X-XSS-Protection "1; mode=block";
      add_header X-Robots-Tag none;
      add_header X-Download-Options noopen;
      add_header X-Permitted-Cross-Domain-Policies none;
      add_header Referrer-Policy no-referrer;
      error_page 403 /core/templates/403.php;
      error_page 404 /core/templates/404.php;
      client_max_body_size ${services.nextcloud.maxUploadSize};
      fastcgi_buffers 64 4K;
      fastcgi_hide_header X-Powered-By;
      gzip on;
      gzip_vary on;
      gzip_comp_level 4;
      gzip_min_length 256;
      gzip_proxied expired no-cache no-store private no_last_modified no_etag auth;
      gzip_types application/atom+xml application/javascript application/json application/ld+json application/manifest+json application/rss+xml application/vnd.geo+json application/vnd.ms-fontobject application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/bmp image/svg+xml image/x-icon text/cache-manifest text/css text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy;
      '';
    };
  };
}
