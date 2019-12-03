{ config, pkgs, ... }:

let

  pkg = pkgs.stdenv.mkDerivation rec {
    pname = "mediawiki-full";
    version = src.version;
    src = cfg.package;

    installPhase = ''
      mkdir -p $out
      cp -r * $out/
      rm -rf $out/share/mediawiki/skins/*
      rm -rf $out/share/mediawiki/extensions/*
      ${concatStringsSep "\n" (mapAttrsToList (k: v: ''
        ln -s ${v} $out/share/mediawiki/skins/${k}
      '') cfg.skins)}
      ${concatStringsSep "\n" (mapAttrsToList (k: v: ''
        ln -s ${v} $out/share/mediawiki/extensions/${k}
      '') cfg.extensions)}
    '';
  };

in
{
  services.nginx.virtualHosts = {
    "wiki.street.ardaxi.com" = {
      forceSSL = true;
      enableACME = true;
      root = "${pkg}/share/mediawiki";
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
          extraConfig = "try_files $uri $uri/ @rewrite;" + allow;
        };
        "@rewrite" = {
          priority = 300;
          extraConfig = "rewrite ^/(.*)$ /index.php?title=$1&$args;" + allow;
        };
        "^~ /maintenance/" = {
          priority = 400;
          extraConfig = "deny all;";
        };
        "~ \.php$" = {
          priority = 500;
          extraConfig = ''
            include ${config.services.nginx.package}/conf/fastcgi.conf;
            fastcgi_split_path_info ^(.+\.php)(\\/.*)$;
            try_files $fastcgi_script_name =404;
            fastcgi_param PATH_INFO $fastcgi_path_info;
            fastcgi_param modHeadersAvailable true;
            fastcgi_param front_controller_active true;
            fastcgi_pass unix:${config.services.phpfpm.pools.nextcloud.socket};
            fastcgi_intercept_errors on;
            fastcgi_request_buffering off;
            fastcgi_read_timeout 120s;
          '' + allow;
        };
        "~* \.(js|css|png|jpg|jpeg|gif|ico)$" = {
          priority = 600;
          extraConfig = ''
            try_files $uri /index.php;
            expires max;
            log_not_found off;
          '' + allow;
        };
        "/_.gif" = {
          priority = 700;
          extraConfig = ''
            expires max;
            empty_gif;
          '' + allow;
        };
        "^~ ^/(cache|includes|maintenance|languages|serialized|tests|images/deleted)/" = {
          priority = 800;
          extraConfig = "deny all;";
        };
        "^~ ^/(bin|docs|extensions|includes|maintenance|mw-config|resources|serialized|tests)/" = {
          priority = 850;
          extraConfig = "internal;";
        };
        "^~ /images/" = {
          priority = 900;
          root = config.services.mediawiki.uploadsDir;
          tryFiles = "$uri /index.php";
          extraConfig = allow;
        };
        "~ /\." = {
          priority = 950;
          extraConfig = ''
            access_log off;
            log_not_found off; 
            deny all;
          '';
        };
      };
     extraConfig = ''
      add_header X-Content-Type-Options nosniff;
      add_header X-XSS-Protection "1; mode=block";
      add_header X-Robots-Tag none;
      add_header X-Download-Options noopen;
      add_header X-Permitted-Cross-Domain-Policies none;
      add_header Referrer-Policy no-referrer;
#      error_page 403 /core/templates/403.php;
#      error_page 404 /core/templates/404.php;
      client_max_body_size 1g;
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
