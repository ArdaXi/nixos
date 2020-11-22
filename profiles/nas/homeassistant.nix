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
        "met"
        "updater"
        "zeroconf"
        "ssdp"
        "mqtt"
        "mobile_app"
        "tado"
        "somfy"
        "brother"
        "ipp"
      ];
    };
  };
}
