{ config, lib, pkgs, ... }:

let
  cfg = config.ardaxi.ports;

  inherit (lib) attrValues mkOption types unique;
in
{
  ###### interface

  options = {
    ardaxi.ports = {
      tcp = mkOption {
        type = types.attrsOf types.port;
        default = {};
        example = { nginx = 80; };
        description = "TCP ports";
      };
      udp = mkOption {
        type = types.attrsOf types.port;
        default = {};
        example = { bind = 53; };
        description = "UDP ports";
      };
    };
  };

  ###### implementation

  config = {
    assertions = let
      tcpList = attrValues cfg.tcp;
    in [
      { assertion = (unique tcpList) == tcpList;
        message = "Multiple definitions for the same TCP port!";
      }
    ];
  };
}
