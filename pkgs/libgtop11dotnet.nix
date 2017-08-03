{ stdenv, fetchFromGitHub, pkgconfig, boost, pcsclite, zlib }:

stdenv.mkDerivation {
  name = "libgtop11dotnet";
  
  src = fetchFromGitHub {
    owner = "AbigailBuccaneer";
    repo = "libgtop11dotnet";
    rev = "f015fa109fe8829c23bb91603e39a0e09dc1d2e3";
    sha256 = "0jbz7x45s64nm4s9694ma4mcxh11q04zjqfi682jrxnp00mngr49";
  };
  
  buildInputs = [ pkgconfig boost pcsclite zlib ];

  meta = {
    description = "libgtop11dotnet";
    homepage = https://github.com/AbigailBuccaneer/libgtop11dotnet;
    license = "LGPL";
    maintainers = [  ];
  };
}
