{ stdenv, fetchFromGitHub, openconnect, intltool, pkgconfig, networkmanager, libsecret
, withGnome ? true, gnome3, procps, kmod, autoreconfHook }:

stdenv.mkDerivation rec {
  name    = "${pname}${if withGnome then "-gnome" else ""}-${version}";
  pname   = "NetworkManager-openconnect";
  major   = "1.2";
  version = "${major}.4";

  src = fetchFromGitHub {
    owner = "dlenski";
    repo = "network-manager-openconnect";
    rev = "e86c9b3641befe50e6b021864e327c5abe368131";
    sha256 = "0jgny6908ny37sq1x9cywi233yk0s5a1y9pxws6jkdb106mwrppk";
  };

  buildInputs = [ openconnect networkmanager libsecret ]
    ++ stdenv.lib.optionals withGnome [ gnome3.gtk gnome3.libgnome_keyring gnome3.gconf gnome3.gcr ];

  autoreconfPhase = "./autogen.sh";

  nativeBuildInputs = [ autoreconfHook intltool pkgconfig ];

  configureFlags = [
    "${if withGnome then "--with-gnome --with-gtkver=3" else "--without-gnome"}"
    "--disable-static"
  ];

  preConfigure = ''
     substituteInPlace "configure" \
       --replace "/sbin/sysctl" "${procps}/bin/sysctl"
     substituteInPlace "src/nm-openconnect-service.c" \
       --replace "/usr/sbin/openconnect" "${openconnect}/bin/openconnect" \
       --replace "/sbin/modprobe" "${kmod}/bin/modprobe"
  '';

  meta = {
    description = "NetworkManager's OpenConnect plugin";
    inherit (networkmanager.meta) maintainers platforms;
  };
}

