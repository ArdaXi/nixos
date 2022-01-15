{ config, pkgs, ... }:

let
  scanbdConf = pkgs.writeText "scanbd.conf"
    ''
      global {
        debug = true
        debug-level = 3
        user = scanner
        group = scanner
        scriptdir = /etc/scanbd/scripts
        pidfile = /var/run/scanbd.pid
        timeout = 500
        environment {
          device = "SCANBD_DEVICE"
          action = "SCANBD_ACTION"
        }

        multiple_actions = true
        action scan {
          filter = "^email.*"
          numerical-trigger {
               from-value = 1
               to-value   = 0
               }
          desc   = "Scan to file"
          script = "test.script"
        }
      }
    '';
in
{
  services.paperless-ng = {
    enable = true;
    address = "127.0.0.1";
    extraConfig = {
      PAPERLESS_OCR_LANGUAGE = "nld+eng";
      PAPERLESS_DBHOST = "localhost";
    };
  };

  users.groups.scanner.gid = config.ids.gids.scanner;
  users.users.scanner = {
    uid = config.ids.uids.scanner;
    group = "scanner";
  };

  environment.etc."scanbd/scanbd.conf".source = scanbdConf;
  environment.etc."scanbd/scripts/test.script".source = "${pkgs.scanbd}/etc/scanbd/test.script";

  systemd.services = {
    paperless-ng-server.serviceConfig.BindReadOnlyPaths = [ "-/etc/paperless.conf" ];
    paperless-ng-web.serviceConfig.BindReadOnlyPaths = [ "-/etc/paperless.conf" ];

    scanbd = {
      enable = false;
      description = "Scanner button polling service";
      documentation = [ "https://sourceforge.net/p/scanbd/code/HEAD/tree/releases/1.5.1/integration/systemd/README.systemd" ];
      script = "${pkgs.scanbd}/bin/scanbd -c /etc/scanbd/scanbd.conf -f";
      wantedBy = [ "multi-user.target" ];
      aliases = [ "dbus-de.kmux.scanbd.server.service" ];
    };


  };

  hardware.sane.enable = true;
}
