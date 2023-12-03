{ ... }:

{
  services.keycloak = {
    enable = true;
    httpPort = "8086";
    bindAddress = "127.0.0.1";

    database = {
      type = "postgresql";
      username = "keycloak";
      host = "127.0.0.1";
      passwordFile = "/var/secrets/keycloak";
      createLocally = false;
      useSSL = false;
    };

    settings = {
      hostname = "keycloak.ardaxi.com";
      http-relative-path = "/auth";
      hostname-strict-backchannel = true;
      proxy = "edge";
    };
  };
}
