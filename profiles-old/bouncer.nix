{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 53589 8448 80 443 5201 ];
  networking.firewall.allowedUDPPorts = [ 5201 ];

  environment.systemPackages = with pkgs; [
    nodejs
  ];

  services.matrix-synapse = {
    enable = true;
    public_baseurl = "https://matrix.ardaxi.com/";
    server_name = "ardaxi.com";
    web_client = true;
    app_service_config_files = [ /home/ardaxi/matrix-appservice-irc/my_registration_file.yaml ];
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
      host = "10.133.35.191";
      database = "synapse";
      user = "synapse";
      password = "1FrZO6kZmlMR9xwhhNwKdXPsWO5fCpqFL";
    };

    registration_shared_secret = "dKoG5cEOizLHxlCflRI3IzrkFfckkG1Y0gLWs5tMfBEkIKcpwRFLrHY";

    url_preview_enabled = true;

    url_preview_ip_range_blacklist = [
      "127.0.0.0/8"
      "10.133.0.0/16"
      "169.254.0.0/16"
    ];
  };

  services.nginx = {
    enable = true;
    user = "matrix-synapse";
    virtualHosts = {
      "matrix.ardaxi.com" = {
        default = true;
        enableACME = true;
        forceSSL = true;
        locations = {
          "/_matrix" = {
            proxyPass = "http://localhost:8008";
            extraConfig = "proxy_set_header X-Forwarded-For $remote_addr;";
          };
        };
      };
    };
  };


#  services.prometheus = {
#    enable = true;
#    extraFlags = [
#      "-storage.local.memory-chunks=50000"
#    ];
#    globalConfig = {
#      scrape_interval = "10s";
#    };
#    nodeExporter = {
#      enable = true;
#      listenAddress = "127.0.0.1";
#    };
#    scrapeConfigs = [
#      { job_name = "prometheus"; static_configs = [ { targets = ["localhost:9090"]; labels = {}; } ];}
#      { job_name = "node"; static_configs = [
#        { targets = ["localhost:9100"]; labels = {}; }
#        { targets = ["pbx.do.ardaxi.com:9100"]; labels = {}; }
#      ];}
#    ];
#  };
}
