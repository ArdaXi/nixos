{ config, lib, pkgs, ... }:
let
  localNet = pkgs.writeText "localnet" ''
    192.168.178.0/24
    45.80.170.80/29
    2a10:3781:19df::/48
  '';
  crtList = pkgs.writeText "crtlist" ''
    ${config.security.acme.certs."street.ardaxi.com".directory}/full.pem ocsp-update on
  '';
  haproxyCfg = pkgs.writeText "haproxy.conf" ''
    global
      stats socket /run/haproxy/haproxy.sock mode 600 level admin
      log stdout local0
      tune.ssl.ocsp-update.mindelay 5m
      tune.ssl.ocsp-update.maxdelay 24h

    defaults
      mode http
      log global
      timeout client 5s
      timeout server 5s
      timeout connect 5s
      timeout tunnel 1h
      option forwardfor
      option http-keep-alive

    frontend fe_main
      bind :4001
      bind :4002 ssl crt-list ${crtList} alpn h2,http/1.1
      bind quic4@:443 ssl crt-list ${crtList} alpn h3

      http-after-response add-header alt-svc 'h3=":443"; ma=60'

      http-request redirect scheme https unless { ssl_fc }

      http-request set-header Host %[hdr(host),lower,regsub(\"^([A-Za-z0-9-.]*)(:[0-9]*)?$\",\1)]
      http-request set-header X-Forwarded-Proto https

      use_backend be_nginx if { path_beg /.well-known/acme-challenge/ }
      use_backend be_stats if { hdr(host) -i stats.street.ardaxi.com }
      use_backend be_ttrss if { hdr(host) -i rss.street.ardaxi.com } { path_end .php }
      use_backend be_radarr if { hdr(host) -i local.street.ardaxi.com } { path_beg /radarr }
      use_backend be_hass if { hdr(host) -i home.street.ardaxi.com }
      use_backend be_hydra if { hdr(host) -i hydra.street.ardaxi.com }
      use_backend be_nix_serve if { hdr(host) -i nix-cache.street.ardaxi.com }
      use_backend be_unifi if { hdr(host) -i unifi.street.ardaxi.com }
      use_backend be_grafana if { hdr(host) -i grafana.street.ardaxi.com }
      use_backend be_lang if { hdr(host) -i lang.ardaxi.com }
      use_backend be_jellyfin if { hdr(host) -i tv.street.ardaxi.com }

      default_backend be_nginx

    backend be_stats
      stats enable
      stats http-request deny unless { src -f ${localNet} }
      stats uri /
      stats refresh 5s

    fcgi-app tt-rss
      log-stderr global
      option keep-conn
      docroot ${config.services.tt-rss.root}/www
      index index.php
      path-info ^(/.+\.php)(/.*)?$

    backend be_ttrss
      filter fcgi-app tt-rss
      server ttrss ${config.services.phpfpm.pools.${config.services.tt-rss.pool}.socket} proto fcgi

    backend be_nginx
      http-response add-header X-Via nginx
      server local 127.0.0.1:443 ssl verify none

    backend be_hass
      server hass 127.0.0.1:${toString config.services.home-assistant.config.http.server_port}

    backend be_radarr
      http-request deny unless { src -f ${localNet} }

      server radarr 127.0.0.1:7878

    backend be_hydra
      server hydra 127.0.0.1:${toString config.services.hydra.port}

    backend be_nix_serve
      server nixserve 127.0.0.1:${toString config.services.nix-serve.port}

    backend be_unifi
      server unifi 127.0.0.1:8443

    backend be_grafana
      server grafana ${config.services.grafana.settings.server.socket}

    backend be_lang
      http-request deny unless { src -f ${localNet} }
      server local 127.0.0.1:9111

    backend be_jellyfin
      http-request deny unless { src -f ${localNet} }
      server local ${config.systemd.services.jellyfin.environment."JELLYFIN_kestrel__socketPath"}
  '';
  cfg = {
    package = pkgs.haproxy;
    user = "haproxy";
    group = "nginx";
  };
in
{
  environment.etc."haproxy.cfg".source = haproxyCfg;

  systemd.services.haproxy = {
    description = "HAProxy";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    reloadTriggers = [ haproxyCfg ];
    serviceConfig = {
      User = cfg.user;
      Group = cfg.group;
      Type = "notify";
      ExecStartPre = [
        # when the master process receives USR2, it reloads itself using exec(argv[0]),
        # so we create a symlink there and update it before reloading
        "${pkgs.coreutils}/bin/ln -sf ${lib.getExe cfg.package} /run/haproxy/haproxy"
        # when running the config test, don't be quiet so we can see what goes wrong
        "/run/haproxy/haproxy -c -f /etc/haproxy.cfg"
      ];
      ExecStart = "/run/haproxy/haproxy -Ws -f /etc/haproxy.cfg -p /run/haproxy/haproxy.pid";
      # support reloading
      ExecReload = [
        "${lib.getExe cfg.package} -c -f /etc/haproxy.cfg"
        "${pkgs.coreutils}/bin/ln -sf ${lib.getExe cfg.package} /run/haproxy/haproxy"
        "${pkgs.coreutils}/bin/kill -USR2 $MAINPID"
      ];
      KillMode = "mixed";
      SuccessExitStatus = "143";
      Restart = "always";
      RuntimeDirectory = "haproxy";
      # upstream hardening options
      NoNewPrivileges = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      SystemCallFilter= "~@cpu-emulation @keyring @module @obsolete @raw-io @reboot @swap @sync";
      # needed in case we bind to port < 1024
      AmbientCapabilities = "CAP_NET_BIND_SERVICE";
    };
  };

  users.users = lib.optionalAttrs (cfg.user == "haproxy") {
    haproxy = {
      group = cfg.group;
      isSystemUser = true;
      extraGroups = [
        config.users.users."${config.systemd.services.grafana.serviceConfig.User}".group
        config.services.jellyfin.group
      ];
    };
  };
}
