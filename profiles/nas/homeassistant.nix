{ config, lib, pkgs, ... }:

let
  pymfy = ps: ps.buildPythonPackage rec {
    pname = "pymfy";
    version = "0.9.0";
    src = ps.fetchPypi {
      inherit pname version;
      sha256 = "sha256-6KB/YAckwRERj7jHrNT3qtoy6JABxMNek5sZhkSBWiM=";
    };
    propagatedBuildInputs = [ ps.requests_oauthlib ];
  };
in
{
  services.home-assistant = {
    enable = true;
    package = pkgs.home-assistant.override {
      extraPackages = ps: [
        (pymfy ps)
      ];
      extraComponents = [
        "buienradar" "backup" "met" "zeroconf" "ssdp" "mqtt" "mobile_app"
        "tado" "brother" "ipp" "overkiz" "tasmota" "nest" "homekit_controller"
        "shelly" "tibber"
      ];
    };

    config = {
      default_config = {};
      homeassistant = {
        unit_system = "metric";
        temperature_unit = "C";
        time_zone = "Europe/Amsterdam";
      };

      automation = "!include automations.yaml";

      http = {
        server_host = [ "127.0.0.1" ];
        use_x_forwarded_for = true;
        trusted_proxies = [ "127.0.0.1" ];
      };
    };
  };
}
