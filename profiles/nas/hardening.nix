{ lib, config, pkgs, ... }:

let
  localService = {
    IPAddressDeny = ["any"];
    IPAddressAllow = ["localhost"];
  };
  nginxUser = "nginx-exporter";
in
{
  systemd.services = {
    grafana = lib.mkIf config.services.grafana.enable {
      confinement = {
        enable = true;
        packages = [ pkgs.coreutils ];
      };

      serviceConfig = {
        StateDirectory = "grafana";
      } // localService;
    };

    "prometheus-nginx-exporter" = {
      confinement = {
        enable = true;
        binSh = null;
      };

      serviceConfig = {
        User = nginxUser;
        Group = nginxUser;
        DynamicUser = false;
      } // localService;
    };
  };

  users.users."${nginxUser}" = {
    description = "Prometheus nginx exporter user";
    isSystemUser = true;
    group = nginxUser;
  };

  users.groups."${nginxUser}" = {};
}
