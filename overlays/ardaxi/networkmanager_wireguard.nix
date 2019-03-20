{ stdenv, fetchFromGitHub, pkgconfig, networkmanager, libsecret, autoreconfHook, intltool, gnome3, networkmanagerapplet, wireguard-tools, kmod }:

stdenv.mkDerivation rec {
  name    = "${pname}-${version}";
  pname   = "NetworkManager-wireguard";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "max-moser";
    repo = "network-manager-wireguard";
    rev = "61646ade26750c52626a44b025cb1b165681c662";
    sha256 = "1d4hq5y3k4qjsd2qc06i3xqh9xnz5za7c7p3m5skkpln04s28ycv";
  };

  buildInputs = [ networkmanager networkmanagerapplet libsecret gnome3.gtk gnome3.libgnome_keyring gnome3.gcr ];

  autoreconfPhase = "./autogen.sh";

  nativeBuildInputs = [ autoreconfHook intltool pkgconfig ];

  configureFlags = [];

  preConfigure = ''
    substituteInPlace "src/nm-wireguard-service.c" \
      --replace "/sbin/modprobe" "${kmod}/bin/modprobe"
      --replace "/usr/sbin/wg-quick" "${wireguard-tools}/bin/wg-quick"
  '';

  meta = {
    description = "NetworkManager's wireguard plugin";
    inherit (networkmanager.meta) maintainers platforms;
  };
}

