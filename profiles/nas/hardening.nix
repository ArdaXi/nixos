{ lib, config, pkgs, ... }:

let
  localService = {
    IPAddressDeny = ["any"];
    IPAddressAllow = ["localhost"];
  };
  nginxUser = "nginx-exporter";
  waitCmd = timeout: port: ''
    ${pkgs.coreutils}/bin/timeout ${toString timeout} ${pkgs.bash}/bin/bash -c \
      'until printf "" 2>>/dev/null >>/dev/tcp/127.0.0.1/${toString port}; \
        do ${pkgs.coreutils}/bin/sleep 0.5; done'
  '';
in
{
  users.users = {
    "${nginxUser}" = {
      description = "Prometheus nginx exporter user";
      isSystemUser = true;
      group = nginxUser;
    };
    ankisyncd = {
      description = "ankisyncd user";
      isSystemUser = true;
      group = "ankisyncd";
    };
  };

  users.groups = {
    "${nginxUser}" = {};
    ankisyncd = {};
  };
}
