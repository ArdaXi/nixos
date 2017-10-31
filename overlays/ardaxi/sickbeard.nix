{stdenv, fetchFromGitHub, python2, par2cmdline, unzip, unrar, p7zip, makeWrapper}:

let
  pythonEnv = python2.withPackages(ps: with ps; [ cheetah ]);
in stdenv.mkDerivation rec {
  version = "508";
  pname = "sickbeard";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "midgetspy";
    repo = "Sick-Beard";
    rev = "171a607e41b7347a74cc815f6ecce7968d9acccf";
    sha256 = "16bn13pvzl8w6nxm36ii724x48z1cnf8y5fl0m5ig1vpqfypk5vq";
  };

  buildInputs = [ pythonEnv ];

  installPhase = ''
    mkdir -p $out
    cp -R * $out/
    mkdir $out/bin
    echo "${pythonEnv}/bin/python $out/SickBeard.py \$*" > $out/bin/sickbeard
    chmod +x $out/bin/sickbeard
  '';

  meta = with stdenv.lib; {
    description = "PVR for newsgroup users";
    homepage = http://sickbeard.com;
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with stdenv.lib.maintainers; [ ];
  };
}
