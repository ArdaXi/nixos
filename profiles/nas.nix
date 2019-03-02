{ config, pkgs, lib, ... }:

{
  imports = [
    ../modules/sickrage.nix
    ../modules/prometheus2.nix
  ];

  networking.firewall.enable = false;

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
        name = "street.ardaxi.com";
        master = true;
        file = builtins.toFile "street.ardaxi.com"
        ''
          $ORIGIN street.ardaxi.com.
          $TTL 1h
          @ IN SOA @ root (1 1h 1h 4w 1h)
          @ IN NS  ns
          @ IN A   192.168.178.2
          * IN A   192.168.178.2
        '';
      } {
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
      outsideSSL = [
        { addr = "0.0.0.0"; port =  80; ssl = false; }
        { addr = "0.0.0.0"; port =  81; ssl = false; }
        { addr = "0.0.0.0"; port =  443; ssl = true; }
        { addr = "0.0.0.0"; port = 6443; ssl = true; }
      ];
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
        enableACME = true;
        listen = outsideSSL;
        locations = {
          "/" = {
            proxyPass = "http://localhost:3000";
            extraConfig = proxyConf;
          };
        };
      };
      "nix-cache.street.ardaxi.com" = {
        enableACME = true;
        listen = outsideSSL;
        locations = {
          "/" = {
            proxyPass = "http://localhost:3001";
            extraConfig = proxyConf;
          };
        };
      };
      "unifi.street.ardaxi.com" = {
        enableACME = true;
        forceSSL = true;
        listen = outsideSSL;
        locations = {
          "/" = {
            proxyPass = "https://localhost:8443";
            extraConfig = proxyConf;
          };
        };
      };
      "grafana.street.ardaxi.com" = {
        enableACME = true;
        forceSSL = true;
        listen = outsideSSL;
        locations = {
          "/" = {
            proxyPass = "http://localhost:4000";
            extraConfig = proxyConf;
          };
        };
      };
      "street.ardaxi.com" = {
        enableACME = true;
        forceSSL = true;
        listen = outsideSSL;
      };
      "local.ardaxi.com" = {
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
            proxyPass = "http://localhost:8081/";
          };
          "/sickrage/" = {
            proxyPass = "http://localhost:8082";
          };
        };
      };
    };
  };

  services.unifi.enable = true;
  services.sabnzbd.enable = true;
  services.sickrage.enable = true;

  networking.extraHosts = "127.0.0.1 ns.street.ardaxi.com";

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
    extraFlags = ["--storage.local.retention.time 365d"];
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
    remoteRead = [{
      url = "http://localhost:9094/api/v1/read";
    }];
    scrapeConfigs = [
      {
        job_name = "inverter";
        scrape_interval = "5m";
        static_configs = [{
          targets = ["192.168.178.1:8080"];
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
}
