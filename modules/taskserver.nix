{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.taskserver;
  taskdConfig = pkgs.writeText "taskserver-config"
    ''
    root=${cfg.dataDir}
    server=${cfg.listenAddress}
    server.cert=${cfg.dataDir}/server.cert.pem
    server.key=${cfg.dataDir}/server.key.pem
    server.crl=${cfg.dataDir}/server.crl.pem
    ca.cert=${cfg.dataDir}/ca.cert.pem
    client.cert=${cfg.dataDir}/client.cert.pem
    client.key=${cfg.dataDir}/client.key.pem
    ${cfg.extraConfig}
    '';

in
{
  options = {
    services.taskserver = {
      enable = mkEnableOption "taskserver";

      dataDir = mkOption {
        default = "/var/lib/taskd";
        type = types.path;
        description = ''
          Specify an alternative location to store the data and config.
        '';
      };

      listenAddress = mkOption {
        default = "0.0.0.0:53589";
        type = types.str;
        description = "The address taskd will listen on.";
      };

      extraConfig = mkOption {
        default = "";
        type = types.lines;
        example = ''
          request.limit=1048576
          family=IPv4
        '';
        description = ''
          Extra configuration options to be appended to the config file.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    users.extraUsers = singleton
    {
      name = "taskd";
      #uid = config.ids.uids.taskd;
      uid = 300;
      description = "Taskserver daemon user";
      home = cfg.dataDir;
      createHome = true;
    };

    systemd.services.taskserver = {
      description = ''
        Secure server providing multi-user, multi-client access to task data
      '';
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      preStart = ''
        ln -sf ${taskdConfig} ${cfg.dataDir}/config
      '';

      serviceConfig = {
        User = "taskd";
        ExecStart = "${pkgs.taskserver}/bin/taskd server --data ${cfg.dataDir}";
        PermissionsStartOnly = true;
      };
    };
  };
}
