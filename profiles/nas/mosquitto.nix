{ ... }:

{
  services.mosquitto = {
    enable = true;
    listeners = [{
      users = {
        homeassistant = {
          acl = [
            "readwrite homeassistant/#"
            "readwrite z2m/+/get"
            "readwrite z2m/+/set"
            "read z2m/#"
          ];
          hashedPasswordFile = "/var/lib/mosquitto/passwords/homeassistant";
        };
        z2m = {
          acl = [
            "readwrite z2m/#"
            "readwrite homeassistant/#"
          ];
          hashedPasswordFile = "/var/lib/mosquitto/passwords/z2m";
        };
      };
    }];
  };
}
