{ config, lib, ... }:

let
  hostname = config.networking.hostName;
  folders = {
    "/home/ardaxi/sync" = {
      id = "try7p-qpztf";
      devices = [ "hiro" "cic" ];
      ignorePerms = false;
    };
  };
  devices = {
    hiro = {
      id = "7H6RLDG-TCZYFKT-DVSN77D-TJEI2W2-CL4WKZU-E52FISN-OP5AU24-STQ74QR";
      addresses = [
        "quic://192.168.178.14"
        "tcp://192.168.178.14"
        "dynamic"
      ];
    };
    cic = {
      id = "A5YMFMQ-SNYPHCG-I62HI2S-24CZI2M-NUGBC53-RWRD7FH-XX4OWH2-ME6PMQU";
      addresses = [
        "quic://192.168.178.14"
        "tcp://192.168.178.14"
        "quic://street.ardaxi.com"
        "tcp://street.ardaxi.com"
      ];
    };
  };
in
{
  services.syncthing = {
    user = "ardaxi";
    dataDir = "/home/ardaxi/syncthing";
    configDir = "/home/ardaxi/.config/syncthing";

    devices = lib.filterAttrs (n: _: n != hostname) devices;
    folders = lib.mapAttrs
      (_: v: v // { devices = lib.remove hostname v.devices; })
      (lib.filterAttrs
        (_: v: builtins.elem hostname v.devices)
        folders);

    enable = lib.mkIf
      (builtins.elem hostname (builtins.attrNames devices))
      true;
  };
}
