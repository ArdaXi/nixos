{ pkgs, lib, config, ... }:

{
  imports = [
    ./firewall.nix
#    ./synapse.nix
#    ./mosquitto.nix
    ./nfs.nix
    ./bind.nix
    ./nginx.nix
    ./prometheus.nix
    ./hydra.nix
    ./downloaders.nix
#    ./docker.nix
    ./hardening.nix
    #./homeassistant.nix
#    ./ipfs.nix
    ./innernet.nix
    ./iscsi.nix
#    ./keycloak.nix
    ./zfs.nix
#    ./upgrade-postgres.nix
    ./paperless.nix
    ./languagetool.nix
    ./tt-rss.nix
    ./zoneminder.nix
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "acme@ardaxi.com";
  };

  environment.systemPackages = [
    pkgs.tmux
    (pkgs.writeShellScriptBin "irc" ''
      T3=$(pidof weechat)

      if [ -z "$T3" ]; then
        ${pkgs.tmux}/bin/tmux new-session -d -s main;
        ${pkgs.tmux}/bin/tmux new-window -t main -n weechat ${pkgs.weechat}/bin/weechat;
      fi
        ${pkgs.tmux}/bin/tmux attach-session -t main;
      exit 0
    '')
  ];

  services = {
    postgresql = {
      enable = true;
      package = pkgs.postgresql_14;
      authentication = "host all all 127.0.0.1/32 trust";
    };

    openldap = {
      enable = false;
      urlList = [ "ldap://127.0.0.1:389/" ];
      configDir = "/var/db/slapd.d";
    };

    gitolite = {
      enable = true;
      adminPubkey = builtins.head config.users.users.ardaxi.openssh.authorizedKeys.keys;
    };

    unifi = let
      heap = 1024;
    in {
      enable = true;
      initialJavaHeapSize = heap;
      maximumJavaHeapSize = heap;
    };

    chrony = {
      enable = true;
      servers = [ "ntp0.nl.uu.net" "ntp1.nl.uu.net" "time1.esa.int" ];
      extraConfig = ''
        rtcfile /var/lib/chrony/chrony.rtc
        allow 192.168.178
      '';
    };

    jellyfin.enable = true;
  };

  programs.msmtp = {
    enable = true;
    setSendmail = true;
    accounts.default = {
      auth = true;
      host = "smtp.freedom.nl";
      port = 587;
      tls = true;
      user = "street@freedom.nl";
      from = "street@freedom.nl";
      passwordeval = "${pkgs.coreutils}/bin/cat /var/secrets/freedom.txt";
    };
  };

  users.users.unifi.group = "unifi";
  users.groups.unifi = {};

}
