{ lib, config, pkgs, ... }:

let
  localService = {
    IPAddressDeny = ["any"];
    IPAddressAllow = ["localhost"];
  };
  nginxUser = "nginx-exporter";
  waitCmd = timeout: port: ''
    ${pkgs.coreutils}/bin/timeout ${toString timeout} ${pkgs.bash}/bin/bash -c \
      'until printf "" 2>>/dev/null >>/dev/tcp/127.0.0.1/${toString port}; \
        do ${pkgs.coreutils}/bin/sleep 0.5; done'
  '';
in
{
  systemd.sockets.ankisyncd-proxy = {
    wantedBy = [ "sockets.target" ];
    listenStreams = [ "/run/ankisyncd/ankisyncd.sock" ];
    socketConfig = {
      SocketUser = "root";
      SocketGroup = config.services.nginx.group;
      SocketMode = "0660";
    };
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
        ExecStartPost = waitCmd 10 config.services.ankisyncd.port; # bit of an ugly hack
      } // localService;

      unitConfig.StopWhenUnneeded = true;
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
