{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.tiddlywiki-user;
  listenParams = concatStrings (mapAttrsToList (n: v: " '${n}=${toString v}' ") cfg.listenOptions);
  exe = "${pkgs.nodePackages.tiddlywiki}/lib/node_modules/.bin/tiddlywiki";
  name = "tiddlywiki";

in {

  options.services.tiddlywiki-user = {

    enable = mkEnableOption "TiddlyWiki nodejs server";

    listenOptions = mkOption {
      type = types.attrs;
      default = {};
      example = {
        credentials = "../credentials.csv";
        readers="(authenticated)";
        port = 3456;
      };
      description = ''
        Parameters passed to <literal>--listen</literal> command.
        Refer to <link xlink:href="https://tiddlywiki.com/#WebServer"/>
        for details on supported values.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.tiddlywiki = {
      description = "TiddlyWiki nodejs server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        StateDirectory = name;
        ExecStartPre = "-${exe} %S/${name} --init server";
        ExecStart = "${exe} %S/${name} --listen ${listenParams}";
      };
    };
  };
}
