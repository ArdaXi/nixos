{ stdenv, fetchFromGitHub, cmake, postgresql }:

# # To enable on NixOS:
# config.services.postgresql = {
#   extraPlugins = [ pkgs.pg_prometheus ];
#   extraConfig = "shared_preload_libraries = 'pg_prometheus'";
# }

stdenv.mkDerivation rec {
  name = "pg-prometheus-${version}";
  version = "0.2.1";

  buildInputs = [ postgresql ];

  src = fetchFromGitHub {
    owner  = "timescale";
    repo   = "pg_prometheus";
    rev    = "refs/tags/${version}";
    sha256 = "1k2wbx10flgqq2rlp5ccqjbyi2kgkbcr5xyh4qbwpr4zyfbadbqr";
  };

  installPhase = ''
    mkdir -p $out/{lib,share/extension}
    cp *.so                              $out/lib
    cp *.control                         $out/share/extension
    cp sql/pg_prometheus--${version}.sql $out/share/extension
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
