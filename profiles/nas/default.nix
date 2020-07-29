{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/sickrage.nix
    ../../modules/prometheus2.nix
    ./firewall.nix
    ./remote-build.nix
    ./synapse.nix
    ./nextcloud.nix
    ./jitsi.nix
#    ./ipfs.nix
    ./grocy.nix
    ./homeassistant.nix
  ];

  security.acme = {
    acceptTerms = true;
    email = "acme@ardaxi.com";
  };

  services.mosquitto = {
    enable = true;
    allowAnonymous = true;
    aclExtraConf = "topic readwrite #";
    users = {};
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      /export       *(insecure,rw,sync,no_subtree_check,crossmnt,fsid=0)
      /export/media *(insecure,rw,sync,no_subtree_check)
    '';
  };
  fileSystems."/export/media" = {
    device = "/media";
    options = [ "bind" ];
  };

  services.bind = {
    enable = true;
    cacheNetworks = [ "192.168.178.0/24" "127.0.0.0/24" "fe80::/64" "::1/128" ];
    forwarders = [ "8.8.4.4" "8.8.8.8" ];
    zones = [{
          name = "local.ardaxi.com";
          master = true;
          file = builtins.toFile "local.ardaxi.com"
          ''
            $ORIGIN local.ardaxi.com.
            $TTL 1h
            @ IN SOA @ root (1 1h 1h 4w 1h)
            @ IN NS  ns
            @ IN A   192.168.178.2
            * IN A   192.168.178.2
          '';
    }];
  };

  services.nginx = {
    enable = true;
    statusPage = true;
    virtualHosts = let
      proxyConf = ''
        proxy_ssl_verify off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forward-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
      '';
      allow = ''
        allow 192.168.178.0/24;
        allow 82.94.130.160/29;
        allow 2001:984:3f27::/48;
        deny all;
      '';
    in {
      "hydra.street.ardaxi.com" = {
        addSSL = true;
        enableACME = true;
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:3000";
            extraConfig = proxyConf;
          };
        };
      };
      "nix-cache.street.ardaxi.com" = {
        enableACME = true;
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:3001";
          };
        };
      };
      "unifi.street.ardaxi.com" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/" = {
            proxyPass = "https://127.0.0.1:8443";
            extraConfig = proxyConf;
          };
        };
      };
      "grafana.street.ardaxi.com" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:4000";
          };
        };
      };
      "street.ardaxi.com" = {
        enableACME = true;
        forceSSL = true;
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
          "/media/" = {
            alias = "/media/";
            extraConfig = "autoindex on;" + allow;
          };
          "/sabnzbd/" = {
            proxyPass = "http://127.0.0.1:8081/";
            extraConfig = allow;
          };
          "/sickrage/" = {
            proxyPass = "http://127.0.0.1:8082";
            extraConfig = allow;
          };
          "/hydra/" = {
            proxyPass = "http://127.0.0.1:3000/";
            extraConfig = allow;
          };
          "/transmission/" = {
            proxyPass = "http://127.0.0.1:9091";
            extraConfig = allow;
          };
        };
      };
    };
  };

  services.unifi = {
    enable = true;
    initialJavaHeapSize = 4096;
    maximumJavaHeapSize = 4096;
  };

  nixpkgs.config.permittedInsecurePackages = [
    "p7zip-16.02" # needed for sabnzbd
  ];
  services.sabnzbd.enable = true;
  services.sickrage.enable = true;
  services.transmission.enable = true;

  services.openssh.ports = [ 22 2222 ];

  services.gitolite = {
    enable = true;
    adminPubkey = builtins.head config.users.extraUsers.ardaxi.openssh.authorizedKeys.keys;
  };

  services.chrony = {
    enable = true;
    servers = [ "ntp0.nl.uu.net" "ntp1.nl.uu.net" "time1.esa.int" ];
    extraConfig = ''
      rtcfile /var/lib/chrony/chrony.rtc
      allow 192.168.178
    '';
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  users.extraUsers.ardaxi.extraGroups = [ "docker" ];

  services.hydra = {
    enable = true;
    hydraURL = "https://hydra.street.ardaxi.com";
    notificationSender = "hydra@localhost";
    useSubstitutes = true;
    extraConfig = "max_output_size = 4294967296";
    package = pkgs.hydra-unstable;
  };

  services.nix-serve = {
    enable = true;
    port = 3001;
    secretKeyFile = "/etc/nix/signing-key.sec";
  };

#  system.autoUpgrade.enable = true;

  environment.systemPackages = with pkgs; [
    inverter-exporter
    tmux
    (writeShellScriptBin "irc" ''
      T3=$(pidof weechat)

      if [ -z "$T3" ]; then
          ${tmux}/bin/tmux new-session -d -s main;
          ${tmux}/bin/tmux new-window -t main -n weechat ${weechat}/bin/weechat;
      fi
          ${tmux}/bin/tmux attach-session -t main;
      exit 0

    '')
  ];

  services.logind.extraConfig = "HandlePowerKey=ignore";

  services.my-prometheus2 = {
    enable = true;
    listenAddress = ":9090";
    extraFlags = ["--storage.tsdb.retention 365d"];
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        listenAddress = "127.0.0.1";
        port = 9100;
      };
      nginx = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9113;
      };
    };
    remoteRead = [
      { url = "http://localhost:9094/api/v1/read"; }
      { url = "http://localhost:9201/read"; }
    ];
    remoteWrite = [
      { url = "http://localhost:9201/write"; }
    ];
    scrapeConfigs = [
      {
        job_name = "inverter";
        scrape_interval = "5m";
        static_configs = [{
          targets = ["192.168.178.1:8080"];
        }];
      }
      {
        job_name = "meter";
        scrape_interval = "10s";
        static_configs = [{
          targets = ["192.168.179.16:8080"];
        }];
      }
      {
        job_name = "node";
        static_configs = [{
          targets = ["127.0.0.1:9100"];
        }];
      }
      {
        job_name = "nginx";
        static_configs = [{
          targets = ["127.0.0.1:9113"];
        }];
      }
      {
        job_name = "prometheus";
        static_configs = [{
          targets = ["127.0.0.1:9090"];
        }];
      }
    ];
  };

  services.grafana = {
    enable = true;
    port = 4000;
  };

  systemd.services.inverter-exporter = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    script = ''
      #!/bin/sh
      exec ${pkgs.inverter-exporter}/bin/inverter
    '';
    serviceConfig = {
      User = "prometheus";
      Restart = "always";
    };
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_9_6;
    extraPlugins = with pkgs.postgresql_9_6.pkgs; [ timescaledb pkgs.pg_prometheus ];
    extraConfig = ''
      shared_preload_libraries = 'timescaledb, pg_prometheus'
    '';

    authentication = "host all all 127.0.0.1/32 trust";
  };

  systemd.services.prometheus-postgresql-adapter = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    script = ''
      #!/bin/sh
      exec ${pkgs.prometheus-postgresql}/bin/prometheus-postgresql-adapter \
        -pg.database prometheus -pg.user prometheus -pg.host 127.0.0.1
    '';
    serviceConfig = {
      User = "prometheus";
      Restart = "always";
      PrivateTmp = true;
      WorkingDirectory = "/tmp";
    };
  };

  services.openldap = {
    enable = true;
    urlList = [ "ldap://127.0.0.1:389/" ];
    configDir = "/var/db/slapd.d";
  };
}
