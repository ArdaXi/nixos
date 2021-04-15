{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.sickrage;
  inherit (pkgs) sickrage;

in

{

  ###### interface

  options = {
    services.sickrage = {
      enable = mkOption {
        default = false;
        description = "Whether to enable the sickrage server.";
      };
      dataDir = mkOption {
        default = "/var/lib/sickrage";
        description = "Path to datadir";
      };

      user = mkOption {
        default = "sickrage";
        description = "User to run the service as";
      };

      group = mkOption {
        default = "sickrage";
        description = "Group to run the service as";
      };
    };
  };


  ###### implementation

  config = mkIf cfg.enable {

    users.extraUsers.sickrage = {
          uid = 2001;
          group = "sickrage";
          description = "sickrage user";
          home = cfg.dataDir;
          createHome = true;
          isSystemUser = true;
    };

    users.extraGroups.sickrage = {
      gid = 2001;
    };

    systemd.services.sickrage = {
        description = "sickrage server";
        wantedBy    = [ "multi-user.target" ];
        after = [ "network.target" ];
        serviceConfig = {
          User = "${cfg.user}";
          Group = "${cfg.group}";
          ExecStart = "${sickrage}/bin/sickrage --nolaunch --datadir ${cfg.dataDir}";
        };
    };
  };
}
