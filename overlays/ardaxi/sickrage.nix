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
    rev = "d8c2613583ce8b321a5adc9ff70c52e830f224a8";
    sha256 = "0frrm8yz961l198ymmb9w7k6c7rzh3b2x8ih7la61m7rj5k3lw6b";
  };

  buildInputs = [ pythonEnv ];

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
