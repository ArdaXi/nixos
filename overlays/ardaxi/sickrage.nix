{stdenv, fetchFromGitHub, python2, unrar, makeWrapper }:

let
  pythonEnv = python2.withPackages(ps: with ps; [ Babel cheetah Mako ]);
  path = stdenv.lib.makeBinPath [ unrar ];
in stdenv.mkDerivation rec {
  version = "0.0.1";
  pname = "SickRage";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "sickrage";
    repo = "sickrage";
    rev = "726b8dc184aea4e7cf656bbd6eb5338f68cbf72a";
    sha256 = "1bk8h3s7p78jmkp5bvgpsizg2296h41j2wbzp1f1jvphs1kigawn";
  };

  buildInputs = [ pythonEnv makeWrapper ];

  installPhase = ''
    mkdir -p $out
    cp -R * $out/
    mkdir $out/bin
    echo "${pythonEnv}/bin/python $out/SickBeard.py \$*" > $out/bin/sickrage
    chmod +x $out/bin/sickrage
    wrapProgram $out/bin/sickrage --set PATH ${path}
  '';

  meta = with stdenv.lib; {
    description = "PVR for newsgroup users";
    homepage = http://sickrage.github.io;
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with stdenv.lib.maintainers; [ ];
  };
}
