{ stdenv, fetchFromGitHub, cmake, postgresql_12 }:

# # To enable on NixOS:
# config.services.postgresql = {
#   extraPlugins = [ pkgs.pg_prometheus ];
#   extraConfig = "shared_preload_libraries = 'pg_prometheus'";
# }

stdenv.mkDerivation rec {
  name = "pg-prometheus-${version}";
  version = "0.2.2";

  buildInputs = [ postgresql_12 ];

  src = fetchFromGitHub {
    owner  = "timescale";
    repo   = "pg_prometheus";
    rev    = "refs/tags/${version}";
    sha256 = "sha256-GdhNO/VEJDbLgxm/mAViwkNkxjx24MucwmDud4zXH+A=";
  };

  installPhase = ''
    mkdir -p $out/{lib,share/postgresql/extension}
    cp *.so                              $out/lib
    cp *.control                         $out/share/postgresql/extension
    cp sql/pg_prometheus--${version}.sql $out/share/postgresql/extension
  '';

  postInstall = ''
    # work around an annoying bug, by creating $out/bin, so buildEnv doesn't freak out later
    # see https://github.com/NixOS/nixpkgs/issues/22653

    mkdir -p $out/bin
  '';

  meta = with stdenv.lib; {
    description = "An extension for PostgreSQL that defines a Prometheus metric samples data type and provides several storage formats for storing Prometheus data";
    homepage    = https://www.timescale.com/;
    maintainers = with maintainers; [  ];
    platforms   = platforms.linux;
    license     = licenses.asl20;
  };
}
