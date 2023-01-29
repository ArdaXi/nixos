{ ... }:

{
  services.mosquitto = {
    enable = true;
    listeners = [{
      users = {
        homeassistant = {
          acl = [
            "readwrite homeassistant/#"
            "read #"
          ];
          hashedPasswordFile = "/var/lib/mosquitto/passwords/homeassistant";
        };
      };
    }];
  };
}
