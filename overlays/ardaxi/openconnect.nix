{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig, vpnc, gnutls, gmp, libxml2, stoken, zlib } :

#assert (openssl != null) == (gnutls == null);

stdenv.mkDerivation rec {
  name = "openconnect-7.08";

  src = fetchFromGitHub {
    owner = "dlenski";
    repo = "openconnect";
    rev = "14dc2c18935e4ce71d34a1868ea7d95e145cd013";
    sha256 = "1qmw3wf799ddbks8w1521wjdxrphc1qxracmbwid1cqslhfkg9rf";
  };

  outputs = [ "out" "dev" ];

  preConfigure = ''
      export PKG_CONFIG=${pkgconfig}/bin/pkg-config
      export LIBXML2_CFLAGS="-I ${libxml2.dev}/include/libxml2"
      export LIBXML2_LIBS="-L${libxml2.out}/lib -lxml2"
    '';

  configureFlags = [
    "--with-vpnc-script=${vpnc}/etc/vpnc/vpnc-script"
    "--disable-nls"
    "--without-openssl-version-check"
  ];

  autoreconfPhase = "./autogen.sh";

  nativeBuildInputs = [ autoreconfHook pkgconfig ];
  propagatedBuildInputs = [ vpnc gnutls gmp libxml2 stoken zlib ];

  meta = {
    description = "VPN Client for Cisco's AnyConnect SSL VPN";
    homepage = http://www.infradead.org/openconnect/;
    license = stdenv.lib.licenses.lgpl21;
    maintainers = with stdenv.lib.maintainers; [ pradeepchhetri ];
    platforms = stdenv.lib.platforms.linux;
  };
}
