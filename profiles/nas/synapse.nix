{ config, pkgs, ... }:

{
  security.acme.certs."matrix.ardaxi.com" = {
    allowKeysForGroup = true;
    group = "matrix-synapse"; 
  };

	services.nginx = {
    virtualHosts = {
      "matrix.ardaxi.com" = {
        http2 = false;
        enableACME = true;
        forceSSL = true;
        locations = {
          "/_matrix" = {
            proxyPass = "http://127.0.0.1:8008";
            extraConfig = "proxy_set_header X-Forwarded-For $remote_addr;";
          };
        };
      };
    };
  };

	services.matrix-synapse = {
    enable = true;
    public_baseurl = "https://matrix.ardaxi.com/";
    server_name = "ardaxi.com";
    web_client = true;
    tls_certificate_path = "/var/lib/acme/matrix.ardaxi.com/fullchain.pem";
    tls_private_key_path = "/var/lib/acme/matrix.ardaxi.com/key.pem";

    rc_messages_per_second = "2.0";
    rc_message_burst_count = "100.0";
    listeners = [
      { bind_address = ""; port = 8448; resources = [ { compress = true; names = [ "client" "webclient" ] ; } { compress = false; names = [ "federation" ] ; } ] ; tls = true; type = "http"; x_forwarded = false; }
      { bind_address = "127.0.0.1"; port = 8008; resources = [ { compress = true; names = [ "client" "webclient" ] ; } { compress = false; names = [ "federation" ] ; } ] ; tls = false; type = "http"; x_forwarded = true; }
    ];
    database_type = "psycopg2";
    database_args = {
      host = "127.0.0.1";
      database = "synapse";
      user = "synapse";
    };

    url_preview_enabled = true;

    url_preview_ip_range_blacklist = [
      "127.0.0.0/8"
      "169.254.0.0/16"
      "192.168.0.0/16"
      "10.0.0.0/8"
    ];
  };
}
