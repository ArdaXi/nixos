{ config, pkgs, lib, ... }:

let
  inherit (lib) types mkOption mkIf mkOverride optionalAttrs nameValuePair;

  portToTarget = port: "127.0.0.1:${toString port}";

  needsServiceOverride = cfg: cfg.proxy.enable &&
    (cfg.proxy.wait || cfg.proxy.socketActivate);
    
  waitCmd = timeout: port: ''
    ${pkgs.coreutils}/bin/timeout ${toString timeout} ${pkgs.bash}/bin/bash -c \
      'until printf "" 2>>/dev/null >>/dev/tcp/127.0.0.1/${toString port}; \
      do ${pkgs.coreutils}/bin/sleep 0.5; done'
  '';
in
{
  options.systemd.services = mkOption {
    type = types.attrsOf (types.submodule {
      options.proxy = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = ''
            If set, create a proxy for this service in the host namespace.
          '';
        };

        target = mkOption {
          type = types.coercedTo types.port portToTarget types.str;
          example = 8080;
          description = ''
            The target to proxy to. Either a string of the form <literal>ip-address:port
            </literal>, a path to a UNIX socket, or an integer which will be interpreted
            as a port on localhost.
          '';
        };

        user = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "root";
          description = ''
            The user who will own the socket. Defaults to the user of this service.
          '';
        };

        group = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "root";
          description = ''
            The group who will own the socket. Defaults to the group of this service.
          '';
        };

        mode = mkOption {
          type = types.str;
          default = "0660";
          example = "0666";
          description = ''
            The file system access mode used when creating the socket.
          '';
        };

        wait = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Whether to include an ExecStartPost script to this service that prevents it
            from reporting ready until the proxied port is available. Without it, the proxy
            may return 'connection refused' if the service is not yet running and does not
            bind its port quickly enough.
          '';
        };

        waitTimeout = mkOption {
          type = types.int;
          default = 10;
          description = ''
            The amount of time to wait for the port to come up before giving up.
          '';
        };

        exitIdleTime = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "15m";
          description = ''
            If set, sets the time before exiting when there are no connections. Takes a
            unit-less value in seconds or a time span value such as
            <literal>15min 20s</literal>
          '';
        };

        listenStream = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "/run/service/service.sock";
          description = ''
            The ListenStream to create. See <citerefentry>
              <refentrytitle>systemd.socket</refentrytitle>
              <manvolnum>5</manvolnum>
            </citerefentry> for more information.
            Defaults to <filename>/run/servicename/servicename.sock</filename>
          '';
        };

        socketActivate = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Whether to rely on socket activation for this service. This will put an override
            (with priority <literal>90</literal>) to remove any <literal>after</literal> or
            <literal>wantedBy</literal> entries for this service.
          '';
        };
      };
    });
  };

  config.systemd.sockets = lib.mapAttrs' (name: cfg: let
    listenStream = if cfg.proxy.listenStream != null then cfg.proxy.listenStream else
      "/run/${name}/${name}.sock";
    user = if cfg.proxy.user != null then cfg.proxy.user else cfg.serviceConfig.User or null;
    group = if cfg.proxy.group != null then cfg.proxy.group else
      cfg.serviceConfig.Group or null;
    socketCfg = {
      wantedBy = [ "sockets.target" ];
      ListenStreams = [ listenStream ];
      socketConfig = {
        SocketUser = mkIf (user != null) user;
        SocketGroup = mkIf (group != null) group;
        SocketMode = cfg.proxy.mode;
      };
    };
  in optionalAttrs cfg.proxy.enable (nameValuePair "${name}-proxy" socketCfg)
    config.systemd.services);

  config.systemd.services = let
    proxies = lib.mapAttrs' (name: cfg: let
      idleOpt = if cfg.proxy.exitIdleTime == null then "" else
        "--exit-idle-time=${cfg.proxy.exitIdleTime}";
      execCmd = ''
        ${config.systemd.package}/lib/systemd/systemd-socket-proxyd ${idleOpt} \
          ${cfg.proxy.target}
      '';
      serviceCfg = {
        requires = [ "${name}.service" "${name}-proxy.socket" ];
        after = [ "${name}.service" "${name}-proxy.socket" ];

        unitConfig.JoinsNamespaceOf = "${name}.service";

        serviceConfig = {
          ExecStart = execCmd;
          PrivateNetwork = cfg.serviceConfig.PrivateNetwork or false;
          User = mkIf (cfg.serviceConfig.User != null) cfg.serviceConfig.User;
          Group = mkIf (cfg.serviceConfig.Group != null) cfg.serviceConfig.Group;
        };
      };
    in optionalAttrs cfg.proxy.enable (nameValuePair "${name}-proxy" serviceCfg))
      config.systemd.services;
    services = lib.mapAttrs (name: cfg: let
      serviceCfg = {
        after = mkIf cfg.proxy.socketActivate (mkOverride 90 []);
        wantedBy = mkIf cfg.proxy.socketActivate (mkOverride 90 []);

        serviceConfig.ExecStartPost = mkIf cfg.proxy.wait
          (waitCmd cfg.proxy.waitTimeout cfg.proxy.target);
      };
    in optionalAttrs (needsServiceOverride cfg) serviceCfg) config.systemd.services;
  in proxies // services;
}
