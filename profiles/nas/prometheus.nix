{ config, pkgs, ... }:

let
  promPort = 9090;
  nodePort = 9100;
  nginxPort = 9113;
in
{
  services.my-prometheus2 = {
    enable = true;
    listenAddress = ":${toString promPort}";
    extraFlags = ["--storage.tsdb.retention 365d"];
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
    remoteRead = [
      { url = "http://localhost:9094/api/v1/read"; }
      { url = "http://localhost:9201/read"; }
    ];
    remoteWrite = [
      { url = "http://localhost:9201/write"; }
    ];
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
        job_name = "meter";
        static_configs = [{ targets = ["192.168.179.16:8080"]; }];
      }
      {
        job_name = "meter_esp_gotsmart";
        metrics_path = "/gotsmart";
        static_configs = [{
          targets = ["192.168.179.138:80"];
          labels = { device = "4530303534303037363139333638373230"; };
        }];
      }
    ];
  };

  services.grafana = {
    enable = true;
    protocol = "socket";
    extraOptions.SERVER_SOCKET = "/run/grafana/grafana.sock";
  };

  systemd.services.grafana.serviceConfig.RuntimeDirectory = "grafana";

  services.postgresql = {
    extraPlugins = [
      config.services.postgresql.package.pkgs.timescaledb
      pkgs.pg_prometheus
    ];
    settings.shared_preload_libraries = "timescaledb, pg_prometheus";
  };

  systemd.services.prometheus-postgresql-adapter = {
    confinement = {
      enable = true;
      binSh = null;
    };
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.prometheus-postgresql}/bin/prometheus-postgresql-adapter \
          -pg.database prometheus -pg.user prometheus -pg.host 127.0.0.1 -log.level warn
      '';
      User = "prometheus";
      Restart = "always";
      WorkingDirectory = "/tmp";
    };
  };
}
