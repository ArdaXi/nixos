{ lib, config, pkgs, ... }:

let
  localService = {
    IPAddressDeny = ["any"];
    IPAddressAllow = ["localhost"];
  };
in
{
  systemd.services = {
    grafana = lib.mkIf config.services.grafana.enable {
      confinement = {
        enable = true;
        packages = [ pkgs.coreutils ];
      };

      serviceConfig = {
        StateDirectory = "grafana";
      } // localService;
    };

    "prometheus-nginx-exporter" = {
      confinement = {
        enable = true;
        binSh = null;
      };

      serviceConfig = {
        DynamicUser = false;
      } // localService;
    };
  };
}
