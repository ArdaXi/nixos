{ stdenv, fetchgit, meson, ninja, intltool, gtk-doc, pkgconfig, networkmanager, gnome3
, libnotify, libsecret, polkit, isocodes, modemmanager, libxml2, docbook_xsl
, mobile-broadband-provider-info, glib-networking, gsettings-desktop-schemas
, libgudev, hicolor-icon-theme, jansson, wrapGAppsHook, webkitgtk, gobjectIntrospection
, libindicator-gtk3, libappindicator-gtk3, withGnome ? false }:

let
  pname = "network-manager-applet";
  version = "1.8.11+12+ga37483c1";
in stdenv.mkDerivation rec {
  name = "${pname}-${version}";

  src = fetchgit {
    url = "https://git.gnome.org/browse/network-manager-applet";
    rev = "a37483c1a364ef3cc1cfa29e7ad51ca108d75674";
    sha256 = "0qygv9zcppdpdi6wfd0c2iglz2c495ab83195xg9ihshg1xghwgm";
  };

  mesonFlags = [
    "-Dselinux=false"
    "-Dappindicator=true"
    "-Dgcr=${if withGnome then "true" else "false"}"
  ];

  outputs = [ "out" "dev" "devdoc" ];

  buildInputs = [
    gnome3.gtk networkmanager libnotify libsecret gsettings-desktop-schemas
    polkit isocodes libgudev
    modemmanager jansson glib-networking
    libindicator-gtk3 libappindicator-gtk3
  ] ++ stdenv.lib.optionals withGnome [ gnome3.gcr webkitgtk ];

  nativeBuildInputs = [ meson ninja intltool pkgconfig wrapGAppsHook gobjectIntrospection gtk-doc docbook_xsl libxml2 ];

  propagatedUserEnvPkgs = [ hicolor-icon-theme ];

  NIX_CFLAGS = [
    ''-DMOBILE_BROADBAND_PROVIDER_INFO=\"${mobile-broadband-provider-info}/share/mobile-broadband-provider-info/serviceproviders.xml\"''
  ];

  postPatch = ''
    chmod +x meson_post_install.py # patchShebangs requires executable file
    patchShebangs meson_post_install.py
  '';

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
      attrPath = "networkmanagerapplet";
    };
  };

  meta = with stdenv.lib; {
    homepage = https://wiki.gnome.org/Projects/NetworkManager;
    description = "NetworkManager control applet for GNOME";
    license = licenses.gpl2;
    maintainers = with maintainers; [ phreedom rickynils ];
    platforms = platforms.linux;
  };
}
