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
    rev = "ab8ddf086a6a9d9d9f051fcdefe9919b9b902414";
    sha256 = "1df21ddhia2c22gwa0xgxjvb7ib2nalyrhx1w80s41l6sipsxwd7";
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

