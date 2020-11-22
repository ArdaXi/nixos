{ config, ... }:

let
  domain = "matrix.ardaxi.com"; # note: also in nginx.nix
  certDir = config.security.acme.certs."${domain}".directory;
in {
  security.acme.certs."${domain}".group = "matrix-synapse";
  users.users.nginx.extraGroups = [ "matrix-synapse" ];

  services.matrix-synapse = {
    enable = true;
    public_baseurl = "https://${domain}/";
    server_name = "ardaxi.com";
    tls_certificate_path = "${certDir}/fullchain.pem";
    tls_private_key_path = "${certDir}/key.pem";

    rc_messages_per_second = "2.0";
    rc_message_burst_count = "100.0";

    listeners = [
      {
        bind_address = "";
        port = 8448;
        resources = [
          { compress = true; names = [ "client" "webclient" ]; }
          { compress = false; names = [ "federation" ]; }
        ];
        tls = true;
        type = "http";
        x_forwarded = false;
      }
      {
        bind_address = "127.0.0.1";
        port = 8008;
        resources = [
          { compress = true; names = [ "client" "webclient" ]; }
          { compress = false; names = [ "federation" ]; }
        ];
        tls = false;
        type = "http";
        x_forwarded = true;
      }
    ];

    database_type = "psycopg2";
    database_args = {
      host = "127.0.0.1";
      database = "synapse";
      user = "synapse";
    };

    url_preview_enabled = false;
  };
}
