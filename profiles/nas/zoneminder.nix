{ ... }:

{
  services.zoneminder = {
    enable = true;
    hostname = "zm.ardaxi.com";
    cameras = 2;
    storageDir = "/var/lib/zoneminder";
    database = {
      username = "zoneminder";
      createLocally = true;
    };
  };
}
