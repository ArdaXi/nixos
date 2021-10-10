{ config, lib, pkgs, ... }:

let
  promPort = 9090;
  nodePort = 9100;
  nginxPort = 9113;
in
{
  services.my-prometheus2 = {
    enable = true;
    listenAddress = ":${toString promPort}";
    extraFlags = ["--storage.tsdb.retention 3650d"];
    exporters = {
      node = {
        enable = true;
        enabledCollectors = ["systemd"];
        disabledCollectors = ["rapl"];
        listenAddress = "127.0.0.1";
        port = nodePort;
      };
      nginx = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = nginxPort;
      };
    };
    globalConfig = {
      scrape_interval = "1m";
    };
    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [{ targets = ["127.0.0.1:${toString promPort}"]; }];
      }
      {
        job_name = "node";
        static_configs = [{ targets = ["127.0.0.1:${toString nodePort}"]; }];
      }
      {
        job_name = "nginx";
        static_configs = [{ targets = ["127.0.0.1:${toString nginxPort}"]; }];
      }
      {
        job_name = "meter_esp_gotsmart";
        metrics_path = "/gotsmart";
        static_configs = [{
          targets = ["192.168.179.138:80"];
          labels = { device = "4530303534303037363139333638373230"; version = "50"; };
        }];
      }
      {
        job_name = "meter_esp";
        static_configs = [{ targets = ["192.168.179.138:80"]; }];
      }

    ];
  };

  services.grafana = {
    enable = true;
    protocol = "socket";
    extraOptions.SERVER_SOCKET = "/run/grafana/grafana.sock";
  };

  systemd.services.grafana.serviceConfig = {
    RuntimeDirectory = "grafana";
    ProtectSystem = lib.mkForce false;
  };
}
