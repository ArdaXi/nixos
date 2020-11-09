{ pkgs, stdenv, fetchurl, nixosTests }:

stdenv.mkDerivation rec {
  pname = "jitsi-meet";
  version = "1.0.4025";

  src = fetchurl {
    url = "https://download.jitsi.org/jitsi-meet/src/jitsi-meet-${version}.tar.bz2";
    sha256 = "0cri009r549dqa7gj4skj82f17sy63csfsixkvm9cjj1i5ndjnbm";
  };

  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    mkdir $out
    mv * $out/
  '';

  passthru.tests = {
    inherit (nixosTests) jitsi-meet;
  };

  meta = with stdenv.lib; {
    description = "Secure, Simple and Scalable Video Conferences";
    longDescription = ''
      Jitsi Meet is an open-source (Apache) WebRTC JavaScript application that uses Jitsi Videobridge
      to provide high quality, secure and scalable video conferences.
    '';
    homepage = "https://github.com/jitsi/jitsi-meet";
    license = licenses.asl20;
    maintainers = with maintainers; [ mmilata ];
    platforms = platforms.all;
  };
}
