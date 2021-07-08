{ pkgs, ... }:

{
  boot.kernelModules = [ "configfs" "target_core_mod" "iscsi_target_mod" ];

  environment.systemPackages = [ pkgs.targetcli ];
}
