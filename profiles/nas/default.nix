{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/sickrage.nix
    ../../modules/prometheus2.nix
    ./firewall.nix
  ];

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
    in {
      "hydra.street.ardaxi.com" = {
        http2 = false;
        addSSL = true;
        enableACME = true;
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:3000";
          };
        };
      };
      "nix-cache.street.ardaxi.com" = {
        http2 = false;
        enableACME = true;
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:3001";
          };
        };
      };
      "unifi.street.ardaxi.com" = {
        http2 = false;
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
        http2 = false;
        enableACME = true;
        forceSSL = true;
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:4000";
          };
        };
      };
      "street.ardaxi.com" = {
        http2 = false;
        default = true;
        enableACME = true;
        forceSSL = true;
      };
      "local.ardaxi.com" = {
        http2 = false;
        extraConfig = ''
          allow 192.168.178.0/24;
          allow 82.94.130.160/29;
          deny all;
        '';
        locations = {
          "/" = {
            alias = "/var/lib/nginx/index/";
            index = "index.html";
          };
          "/media" = {
            alias = "/media";
            extraConfig = "autoindex on;";
          };
          "/sabnzbd/" = {
            proxyPass = "http://127.0.0.1:8081/";
          };
          "/sickrage/" = {
            proxyPass = "http://127.0.0.1:8082";
          };
          "/hydra/" = {
            proxyPass = "http://127.0.0.1:3000/";
          };
        };
      };
    };
  };

  services.unifi.enable = true;
  services.sabnzbd.enable = true;
  services.sickrage.enable = true;

  services.openssh.ports = [ 22 2222 ];

  services.gitolite = {
    enable = true;
    adminPubkey = builtins.head config.users.extraUsers.ardaxi.openssh.authorizedKeys.keys;
  };

  systemd.services.tahoe = {
    description = "Tahoe-LAFS";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.tahoelafs ];

    serviceConfig = {
      Type = "simple";
      PIDFile = "/run/tahoe.pid";
      ExecStart = ''
        ${pkgs.tahoelafs}/bin/tahoe start /tahoe/tahoe -n -l- --pidfile=/run/tahoe
      '';
    };
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
  };

  services.nix-serve = {
    enable = true;
    port = 3001;
    secretKeyFile = "/etc/nix/signing-key.sec";
  };

  system.autoUpgrade.enable = true;

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

  services.prometheus = {
    enable = true;
    configText = "";
    listenAddress = ":9094";
  };

  services.prometheus2 = {
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
    extraPlugins = with pkgs; [ timescaledb pg_prometheus ];
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
}
