{ pkgs, ... }:

let
  udiskieConfig = {
    program_options = {
      tray = "auto";
      automount = true;
    };
    device_config = [
      { device_file = "/dev/sdb"; has_media = false; ignore = true; }
    ];
    quickmenu_actions = ["mount" "unmount"];
  };
  udiskieConfigFile = pkgs.writeText "udiskie-config.json" (builtins.toJSON udiskieConfig);
in
{
  services = {
    udisks2.enable = true;

    udev.extraRules = ''
      ENV{ID_FS_USAGE}=="filesystem|other|crypto", ENV{UDISKS_FILESYSTEM_SHARED}="1"
    '';
  };

  systemd = {
    user.services.udiskie = {
      serviceConfig.ExecStart = "${pkgs.udiskie}/bin/udiskie -c ${udiskieConfigFile}";

      wantedBy = [ "graphical-session.target" ];
      partOf   = [ "graphical-session.target" ];
    };

#    mounts = [{
#      what = "tmpfs";
#      where = "/media";
#      type = "tmpfs";
#      mountConfig.Options = [ "mode=1777" "strictatime" "rw" "nosuid" "nodev" "size=1M" ];
#    }];
  };
}
