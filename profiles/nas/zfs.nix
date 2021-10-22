{ config, lib, pkgs, ... }:

{
  services = {
    syncoid = {
      enable = true;
      commands = {
        "tank/system/nixos" = {
          target = "scratch/nixos";
          sendOptions = "L";
          recvOptions = "o compression=zstd-4 o recordsize=1M";
          localSourceAllow = [
            "bookmark" "hold" "send" "snapshot" "mount" "destroy"
            "compression" "recordsize"
          ];
          localTargetAllow = [
            "change-key" "compression" "create" "mount" "mountpoint"
            "receive" "rollback" "destroy" "recordsize"
          ]; 
        };
      };
    };

    zfs = {
      autoScrub = {
        enable = true;
        interval = "Friday, 23:00";
      };

      zed.settings = let
        host = config.networking.hostName or "unknown"
             + lib.optionalString (config.networking.domain != null)
                 ".${config.networking.domain}";
        sender = "street@freedom.nl";
        recipient = "street@ardaxi.com";
        mail = pkgs.writeShellScriptBin "mail" ''
          SUBJECT=$1
          shift
          (
            echo "From: ZFS on ${host} <${sender}>";
            echo "To: ${recipient}";
            echo "Subject: $SUBJECT";
            ${pkgs.coreutils}/bin/cat -; 
          ) | /run/wrappers/bin/sendmail $@
        '';
      in
      {
        ZED_DEBUG_LOG = "/tmp/zed.debug.log";
        ZED_EMAIL_ADDR = recipient;
        ZED_EMAIL_PROG = "${mail}/bin/mail";
        ZED_EMAIL_OPTS = "'@SUBJECT@' -a default @ADDRESS@";
        ZED_NOTIFY_INTERVAL_SECS = 3600;
      };
    };
  };
}
