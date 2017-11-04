{ config, pkgs, lib, ... }:

{
  imports = [ ../modules/sickrage.nix ];

  networking.firewall.enable = false;

  services.nfs.server = {
    enable = true;
    exports = ''
      /export       *(insecure,rw,sync,no_subtree_check,crossmnt,fsid=0)
      /export/media *(insecure,rw,sync,no_subtree_check)
    '';
  };
  fileSystems."/export/media" = {
    device = "/media";
    options = [ "bind" ];
  };

  services.bind = {
    enable = true;
    cacheNetworks = [ "192.168.178.0/24" "127.0.0.0/24" "fe80::/64" "::1/128" ];
    forwarders = [ "192.168.178.1" ];
    zones = [{
      name = "street.ardaxi.com";
      master = true;
      file = builtins.toFile "street.ardaxi.com"
      ''
$ORIGIN street.ardaxi.com.
$TTL 1h
@ IN SOA @ root (1 1h 1h 4w 1h)
@ IN NS  ns
@ IN A   192.168.178.2
* IN A   192.168.178.2
      '';
    } {
      name = "local.ardaxi.com";
      master = true;
      file = builtins.toFile "local.ardaxi.com"
      ''
$ORIGIN local.ardaxi.com.
$TTL 1h
@ IN SOA @ root (1 1h 1h 4w 1h)
@ IN NS  ns
@ IN A   192.168.178.2
* IN A   192.168.178.2
      '';
    }];
  };

  services.nginx = {
    enable = true;
    virtualHosts = let
      outsideSSL = [
        { addr = "0.0.0.0"; port =  80; ssl = false; }
        { addr = "0.0.0.0"; port =  81; ssl = false; }
        { addr = "0.0.0.0"; port =  443; ssl = true; }
	{ addr = "0.0.0.0"; port = 6443; ssl = true; }
      ];
    in {
      "unifi.street.ardaxi.com" = {
        enableACME = true;
	forceSSL = true;
	listen = outsideSSL;
	locations = {
	  "/" = {
	    proxyPass = "https://localhost:8443";
	    extraConfig = ''
	      proxy_ssl_verify off;
	      proxy_set_header Host $host;
	      proxy_set_header X-Real-IP $remote_addr;
	      proxy_set_header X-Forward-For $proxy_add_x_forwarded_for;
	      proxy_http_version 1.1;
	      proxy_set_header Upgrade $http_upgrade;
	      proxy_set_header Connection "upgrade";
	    '';
	  };
	};
      };
      "local.ardaxi.com" = {
        locations = {
	  "/" = {
	    alias = "/var/lib/nginx/index/";
	    index = "index.html";
	  };
	  "/media" = {
	    alias = "/media";
	    extraConfig = "autoindex on;";
	  };
	  "/sabnzbd/" = {
	    proxyPass = "http://localhost:8081/";
	  };
    "/sickrage" = {
      proxyPass = "http://localhost:8082/";
    };
	};
      };
    };
  };

  services.unifi.enable = true;
  services.sabnzbd.enable = true;
  services.sickrage.enable = true;

  networking.extraHosts = "127.0.0.1 ns.street.ardaxi.com";
}
