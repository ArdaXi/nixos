{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.sickbeard;
  inherit (pkgs) sickbeard;

in

{

  ###### interface

  options = {
    services.sickbeard = {
      enable = mkOption {
        default = false;
        description = "Whether to enable the sickbeard server.";
      };
      dataDir = mkOption {
        default = "/var/lib/sickbeard";
        description = "Path to datadir";
      };

      user = mkOption {
        default = "sickbeard";
        description = "User to run the service as";
      };

      group = mkOption {
        default = "sickbeard";
        description = "Group to run the service as";
      };
    };
  };


  ###### implementation

  config = mkIf cfg.enable {

    users.extraUsers.sickbeard = {
          uid = 2000;
          group = "sickbeard";
          description = "sickbeard user";
          home = cfg.dataDir;
          createHome = true;
    };

    users.extraGroups.sickbeard = {
      gid = 2000;
    };

    systemd.services.sickbeard = {
        description = "sickbeard server";
        wantedBy    = [ "multi-user.target" ];
        after = [ "network.target" ];
        serviceConfig = {
          Type = "forking";
          GuessMainPID = "no";
          User = "${cfg.user}";
          Group = "${cfg.group}";
          ExecStart = "${sickbeard}/bin/sickbeard -d --nolaunch --datadir=${cfg.dataDir}";
        };
    };
  };
}
