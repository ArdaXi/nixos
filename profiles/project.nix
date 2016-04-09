# This file contains all packages that are only needed for my current project, and should be reconsidered on switching.
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    consul
  ];

  services.consul = {
    enable = true;
    webUi = true;
    extraConfig = { 
      server = true;
      bootstrap = true;
    };
  };

  services.elasticsearch = {
    enable = true;
    plugins = [
#      pkgs.elasticsearchPlugins.elasticsearch_kopf
    ];
    extraConf = ''
      http.cors.enabled: true
      http.cors.allow-origin: "*"
      index.number_of_shards: 1
      index.number_of_replicas: 0
    '';
  };
}
