{ ... }:

{
  services.keycloak = {
    enable = true;

    database = {
      type = "postgresql";
      username = "keycloak";
      host = "127.0.0.1";
      passwordFile = "/var/secrets/keycloak";
      createLocally = false;
      useSSL = false;
    };

    settings = {
      http-host = "127.0.0.1";
      http-port = 8086;
      http-relative-path = "/auth";
      hostname = "keycloak.ardaxi.com";
      hostname-strict-backchannel = true;
      proxy = "edge";
    };
  };
}
