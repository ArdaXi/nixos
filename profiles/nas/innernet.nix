{ pkgs, ... }:

{
  systemd.services.innernet = {
    description = "innernet server for street";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    environment.RUST_LOG = "info";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.innernet}/bin/innernet-server serve street";
      Restart = "always";
      RestartSec = 1;
    };
  };
}
