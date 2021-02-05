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
    ankisyncd = {
      confinement.enable = true;

      serviceConfig = {
        User = "ankisyncd";
        Group = "ankisyncd";
        DynamicUser = lib.mkForce false;
        BindReadOnlyPaths = ["/etc/ankisyncd/ankisyncd.conf"];
      } // localService;
    };

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
        BindReadOnlyPaths = ["/etc/hosts"];
      } // localService;
    };
  };

  users.users = {
    "${nginxUser}" = {
      description = "Prometheus nginx exporter user";
      isSystemUser = true;
      group = nginxUser;
    };
    ankisyncd = {
      description = "ankisyncd user";
      isSystemUser = true;
      group = "ankisyncd";
    };
  };

  users.groups = {
    "${nginxUser}" = {};
    ankisyncd = {};
  };
}
