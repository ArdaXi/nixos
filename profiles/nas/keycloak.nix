{ ... }:

{
  services.keycloak = {
    enable = true;
    httpPort = "8086";
    bindAddress = "127.0.0.1";
    frontendUrl = "keycloak.ardaxi.com/auth";
    forceBackendUrlToFrontendUrl = true;

    database = {
      type = "postgresql";
      passwordFile = "/run/keys/keycloak_password";
      createLocally = true;
    };

    extraConfig = {
      "subsystem=undertow"."server=default-server"."http-listener=default".proxy-address-forwarding="true";
    };
  };
}
