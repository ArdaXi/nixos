{ pkgs, ... }:
let
  authFile = "/etc/vpn.auth";
in
{
  services.openvpn.servers.client = {
    autoStart = false;
    config = ''
      client
      dev tun
      proto tcp
      remote 94.142.241.124 443
      resolv-retry infinite
      nobind
      persist-key
      persist-tun
      ca ${pkgs.fetchurl {
        url = https://weho.st/ca.crt;
        sha256 = "1x7jr0yfqzr27cg5mq5ysm4z5g9gpz5ainp952jj0bfnrpvzlz10";
      }}
      ns-cert-type server
      comp-lzo
      verb 3
      auth-user-pass ${authFile}
    '';
  };
  systemd.services.openvpn-client.unitConfig.AssertFileNotEmpty = authFile;
}
