{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig, vpnc, gnutls, gmp, libxml2, stoken, zlib } :

#assert (openssl != null) == (gnutls == null);

stdenv.mkDerivation rec {
  name = "openconnect-7.08";

  src = fetchFromGitHub {
    owner = "dlenski";
    repo = "openconnect";
    rev = "7b86b5f8024953ef006b653e126e2d6f568e2b75";
    sha256 = "09lid2mbysh5zlyypkqn19d5rwja8d7iviiq27xhm4gfn0s6jk9p";
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
