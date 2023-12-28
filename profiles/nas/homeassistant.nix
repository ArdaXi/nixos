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
  nordpool = ps: ps.buildPythonPackage rec {
    pname = "nordpool";
    version = "0.3.3";
    format = "setuptools";
    src = ps.fetchPypi {
      inherit pname version;
      hash = "sha256-B29dJOk6t2QFhxjFllMyFHoYp07u7oOJPdTrna47dC0=";
    };
    propagatedBuildInputs = with ps; [ python-dateutil pytz requests ];
    pythonImportsCheck = [ "nordpool" ];
  };
  pymiele = ps: ps.buildPythonPackage rec {
    pname = "pymiele";
    version = "0.1.6";
    format = "setuptools";
    src = ps.fetchPypi {
      inherit pname version;
      hash = "sha256-m9TO4ixsuatVCKAOvk10d8XHLK5mQcCpjh2n+of17pY=";
    };
    propagatedBuildInputs = with ps; [ aiohttp async-timeout ];
    pythonImportsCheck = [ "pymiele" ];
    patchPhase = ''
      substituteInPlace setup.py --replace "asyncio" ""
    '';
  };
in
{
  services.udev.extraRules = ''
    SUBSYSTEMS=="usb", ATTR{idVendor}=="1a86", ATTR{idProduct}=="55d4", MODE="0600", OWNER="hass"
  '';

  services.home-assistant = {
    enable = true;
    package = pkgs.home-assistant.override {
      extraPackages = ps: [
        (pymfy ps) (nordpool ps) (pymiele ps) ps.flatdict
      ];
      extraComponents = [
        "buienradar" "backup" "met" "zeroconf" "ssdp" "mqtt" "mobile_app"
        "tado" "brother" "ipp" "overkiz" "tasmota" "nest" "homekit_controller"
        "shelly" "tibber" "zha"
      ];
    };

    config = {
      default_config = {};
      homeassistant = {
        unit_system = "metric";
        temperature_unit = "C";
        time_zone = "Europe/Amsterdam";
      };

      zha_toolkit = {};

      automation = "!include automations.yaml";
      sensor = "!include sensor.yaml";

      http = {
        server_host = [ "127.0.0.1" ];
        use_x_forwarded_for = true;
        trusted_proxies = [ "127.0.0.1" ];
      };
    };
  };
}
