{ lib, config, pkgs, ... }:

let
  localService = {
    IPAddressDeny = ["any"];
    IPAddressAllow = ["localhost"];
  };
  nginxUser = "nginx-exporter";
in
{
  systemd.sockets.ankisyncd-proxy = {
    wantedBy = [ "sockets.target" ];
    listenStreams = [ "/run/ankisyncd/ankisyncd.sock" ];
  };

  systemd.services = {
    ankisyncd-proxy = {
      requires = [ "ankisyncd.service" "ankisyncd-proxy.socket" ];
      after = [ "ankisyncd.service" "ankisyncd-proxy.socket" ];

      confinement.enable = true;

      unitConfig = {
        JoinsNamespaceOf = "ankisyncd.service";
      };

      serviceConfig = {
        ExecStart = ''
          ${config.systemd.package}/lib/systemd/systemd-socket-proxyd --exit-idle-time=15m \
            127.0.0.1:${toString config.services.ankisyncd.port}
        '';
        PrivateNetwork = true;
        User = "ankisyncd";
        Group = "ankisyncd";
      };
    };

    ankisyncd = {
      after = lib.mkForce [];
      wantedBy = lib.mkForce [];
      confinement.enable = true;

      serviceConfig = {
        User = "ankisyncd";
        Group = "ankisyncd";
        DynamicUser = lib.mkForce false;
        BindReadOnlyPaths = ["/etc/ankisyncd/ankisyncd.conf"];
        PrivateNetwork = true;
      } // localService;

      unitConfig.StopWhenUnneeded = true;
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
