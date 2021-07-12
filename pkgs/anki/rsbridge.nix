{ stdenv, rustPlatform, fetchCrate, buildRustCrate, fetchurl, lib, pkg-config, 
  openssl, protobuf, python3, fetchFromGitHub }:

let
  rslib_ftl = fetchFromGitHub {
    owner = "ankitects";
    repo = "anki-core-i18n";
    rev = "bd66b3656c3a59359c26e83b6b9f8da2c8f8b121";
    sha256 = "sha256-HjvZdn2HXkP7pLXsXmfY7ztiZ9qfvS2klXl4OtYWrTA=";
  };
  extra_ftl = fetchFromGitHub {
    owner = "ankitects";
    repo = "anki-desktop-ftl";
    rev = "71f0ec8bf324bf8980ff51bf79e93f140bb004cf";
    sha256 = "sha256-xMgfbZqZAq+K/NjBE0Fl9qDndqiUXw9G2PIZRZ2gXPc=";
  };
in
rustPlatform.buildRustPackage {
  pname = "rsbridge";
  version = "2.1.44";
  src = fetchurl {
    urls = [ "https://github.com/ankitects/anki/archive/2.1.44.tar.gz" ];
    sha256 = "sha256-wkyHqsBCs6yAPqImaQkXMKSLV17p2ZOWctRsr20yh7U=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [ openssl python3 ];

  PROTOC = "${protobuf}/bin/protoc";
  PROTOC_INCLUDE="${protobuf}/include";
  PYO3_PYTHON="${python3}/bin/python";

  BUILDINFO = ./buildinfo.txt;
  BAZEL = "dummy";

  cargoPatches = [ ./lexical_core.patch ];

  cargoHash = "sha256-bUlNpAjqEww3LailKNmY/BSx9coUWOLGwWpe/OCeeKM=";
#  cargoHash = lib.fakeHash;

  buildAndTestSubdir = "pylib/rsbridge";

  doCheck = false;

  RSLIB_FTL_ROOT = "${rslib_ftl}/l10n.toml";
  EXTRA_FTL_ROOT = "${extra_ftl}/l10n.toml";
  OUT_DIR = ".";

}
