{ config, pkgs, lib, ... }:

let
  newPgVer = pkgs.postgresql_12;
  plugins = postgres: [
    postgres.pkgs.timescaledb (pkgs.pg_prometheus.override { postgresql_9_6 = postgres; })
  ];
  withPlugins = postgres: (postgres.withPackages (_: (plugins postgres)));
  oldWithPlugins = withPlugins config.services.postgresql.package;
  newWithPlugins = withPlugins newPgVer;
in
{
  containers.temp-pg.config.services.postgresql = {
    enable = true;
    package = newPgVer;
    extraPlugins = plugins newPgVer;
    settings.shared_preload_libraries = "timescaledb, pg_prometheus";
  };
  environment.systemPackages =
    let
      newpg = config.containers.temp-pg.config.services.postgresql;
      toStr = value:
        if true == value then "yes"
        else if false == value then "no"
        else if lib.isString value then "'${lib.replaceStrings ["'"] ["''"] value}'"
        else toString value;
      configFile = pkgs.writeText "postgresql.conf" (lib.concatStringsSep "\n" (lib.mapAttrsToList (n: v: "${n} = ${toStr v}") newpg.settings));
    in [
      (pkgs.writeScriptBin "upgrade-pg-cluster" ''
        set -x
        export OLDDATA="${config.services.postgresql.dataDir}"
        export NEWDATA="${newpg.dataDir}"
        export OLDBIN="${oldWithPlugins}/bin"
        export NEWBIN="${newWithPlugins}/bin"

        install -d -m 0700 -o postgres -g postgres "$NEWDATA"
        cd "$NEWDATA"
        sudo -u postgres $NEWBIN/initdb -D "$NEWDATA"

        ln -sfn "${configFile}" "$NEWDATA/postgresql.conf"

        systemctl stop postgresql    # old one

        sudo -u postgres $NEWBIN/pg_upgrade \
          --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
          --old-bindir $OLDBIN --new-bindir $NEWBIN \
          "$@"
      '')
    ];
}
