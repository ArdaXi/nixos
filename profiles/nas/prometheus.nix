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
      snmp = {
        enable = true;
        configurationPath = "/etc/snmp.yml";
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
      {
        job_name = "snmp";
        scrape_interval = "10s";
        metrics_path = "/snmp";
        params.module = [ "if_mib" ];
        relabel_configs = [
          { source_labels = ["__address__"]; target_label = "__param_target"; }
          { source_labels = ["__param_target"]; target_label = "instance"; }
          { target_label = "__address__"; replacement = "127.0.0.1:9116"; }
        ];
        static_configs = [{
          targets = [
            "192.168.178.1"
            "192.168.178.60"
          ];
        }];
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
