{ pkgs, ... }:

{
  boot.kernelModules = [ "configfs" "target_core_mod" "iscsi_target_mod" ];

  environment.systemPackages = [ pkgs.targetcli ];

  systemd.services.iscsi-target = {
    enable = true;
    after = [ "network.target" "local-fs.target" ];
    requires = [ "sys-kernel-config.mount" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.python3.pkgs.rtslib}/bin/targetctl restore";
      ExecStop = "${pkgs.python3.pkgs.rtslib}/bin/targetctl clear";
      RemainAfterExit = "yes";
    };
  };
}
