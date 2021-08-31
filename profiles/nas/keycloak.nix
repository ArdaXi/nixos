{ ... }:

{
  services.keycloak = {
    enable = true;
    httpPort = "8086";
    bindAddress = "127.0.0.1";
    frontendUrl = "https://keycloak.ardaxi.com/auth";
    forceBackendUrlToFrontendUrl = true;

    database = {
      type = "postgresql";
      username = "keycloak";
      host = "127.0.0.1";
      passwordFile = "/run/keys/keycloak_password";
      createLocally = false;
      useSSL = false;
    };

    extraConfig = {
      "subsystem=undertow"."server=default-server"."http-listener=default".proxy-address-forwarding="true";
    };
  };
}
