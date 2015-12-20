{ stdenv, callPackage, fetchurl, libXau, libXcomposite, libXcursor, libXdamage, libXdmcp,
  libXfixes, libXft, libXinerama, libXrandr, libXrender, libaio, atk, atkmm,
  at_spi2_core, cairo, cairomm, curl, fontconfig, freetype, fuse, gtk,
  libgcrypt_1_5, gdk_pixbuf, gtkmm, glib, glibmm, pangomm,
  icu, expat, libsigcxx, libxml2, openssl, xmlrpc_c, libgtop,
  librsvg, libpng12, libpng, libtiff, zlib, libgksu, libICE,
  libSM, libX11, libxcb, libXext, libXi, libXtst, pango, pangox_compat,
  hicolor_icon_theme, dbus, gnome}:
#TODO: check openssl (ebuild says 0.9.8)
#TODO: check libtiff (ebuild says 3)
let
  bundleExtract = callPackage ../bundle-extract {};
in
stdenv.mkDerivation rec {
  name = "vmware-workstation-${version}-${build}";
  version = "11.1.2";
  build = "2780323";

  buildInputs = [ 
    bundleExtract libXau libXcomposite libXcursor libXdamage libXdmcp
    libXfixes libXft libXinerama libXrandr libXrender libaio atk atkmm
    at_spi2_core cairo cairomm curl fontconfig freetype fuse gtk
    libgcrypt_1_5 gdk_pixbuf gtkmm glib glibmm gnome.libgnomecanvasmm pangomm
    icu expat libsigcxx libxml2 openssl xmlrpc_c gnome.libgnomecanvas libgtop
    librsvg gnome.ORBit2 gnome.libart_lgpl libpng12 libpng libtiff zlib libgksu
    libICE libSM libX11 libxcb libXext libXi libXtst pango pangox_compat
    gnome.startup_notification hicolor_icon_theme dbus
  ];
  src = fetchurl {
    url = "https://softwareupdate.vmware.com/cds/vmw-desktop/ws/${version}/${build}/linux/core/VMware-Workstation-${version}-${build}.x86_64.bundle.tar";
    sha256 = "0pvjyn747c22n6rxxh3c4knnb4ngsf38466bnbc4fdi5bcbm0nq8";
  };

  preferLocalBuild = true;
  unpackPhase = ''
    tar xvvf $src
    local component; for component in \
      vmware-vmx \
      vmware-player-app \
      vmware-player-setup \
      vmware-workstation \
      vmware-network-editor \
      vmware-network-editor-ui \
      vmware-usbarbitrator \
      vmware-vprobe
    do
      vmware-bundle_extract-bundle-component *.bundle $component $PWD
    done
  '';

  preConfigure = ''
    rm -f bin/vmware-modconfig
    rm -rf lib/modules/binary
    mv lib/libvmware-netcfg.so lib/lib/
    find "$PWD" -name '*.a' -delete
    local libname; for libname in \
      libXau.so.6 \
      libXcomposite.so.1 \
      libXcursor.so.1 \
      libXdamage.so.1 \
      libXdmcp.so.6 \
      libXfixes.so.3 \
      libXft.so.2 \
      libXinerama.so.1 \
      libXrandr.so.2 \
      libXrender.so.1 \
      libaio.so.1 \
      libatk-1.0.so.0 \
      libatkmm-1.6.so.1 \
      libatspi.so.0 \
      libcairo.so.2 \
      libcairomm-1.0.so.1 \
      libcurl.so.4 \
      libdbus-1.so.3 \
      libfontconfig.so.1 \
      libfreetype.so.6 \
      libfuse.so.2 \
      libgailutil.so.18 \
      libgdk-x11-2.0.so.0 \
      libgcrypt.so.11 \
      libgdk_pixbuf-2.0.so.0 \
      libgdkmm-2.4.so.1 \
      libgio-2.0.so.0 \
      libgiomm-2.4.so.1
    do
      rm -r lib/lib/$libname
    done
  '';

  installPhase = ''
    for f in bin/*; do
      substituteInPlace $f --replace /etc/vmware $out/etc/vmware
    done
    bin="$out/bin"
    mkdir -p $bin
    install bin/* $bin

    lib="$out/lib/vmware"
    mkdir -p $lib
    cp -r lib/* $lib

    # Gentoo Bug 432918
    #ln -s $lib/lib/libcrypto.so.0.9.8/libcrypto.so.0.9.8 \ 
    #       $lib/lib/libvmwarebase.so.0/libcrypto.so.0.9.8
    #ln -s $lib/lib/vmware/lib/libssl.so.0.9.8/libssl.so.0.9.8 \
    #       $lib/lib/vmware/lib/libvmwarebase.so.0/libssl.so.0.9.8

    share="$out/share"
    mkdir -p $share
    cp -r share/* $share

    xdg="$out/etc/xdg"
    mkdir -p $xdg
    cp -r etc/xdg/* $xdg

    man="$out/man/man1"
    mkdir -p $man
    install man/man1/vmware.1.gz $man

    setup="$lib/setup"
    mkdir -p $setup
    install vmware-config $setup

    local tool ; for tool in \
      thnuclnt vmware vmplayer{,-daemon} licenseTool vmamqpd \
      vmware-{acetool,enter-serial,gksu,fuseUI,modconfig{,-console},netcfg,tray,unity-helper,zenity}
    do
      ln -s appLoader $lib/bin/$tool
    done

    chmod 0755 $lib/bin/{appLoader,fusermount,launcher.sh,mkisofs,vmware-remotemks}
    chmod 0755 $lib/lib/{wrapper-gtk24.sh,libgksu2.so.0/gksu-run-helper}
    chmod 0755 $lib/setup/vmware-config
    chmod 4711 $lib/bin/vmware-vmx{,-debug,-stats}
    chmod 4711 $bin/vmware-mount

    etc=$out/etc/vmware
    mkdir -p $etc

    cat > $etc/bootstrap <<-EOF
           BINDIR='$bin'
           LIBDIR='$out/lib'
    EOF

    cat > $etc/config <<-EOF
      bindir = "$bin"
      libdir = "$lib"
      initscriptdir = "/etc/init.d"
      authd.fullpath = "$out/sbin/vmware-authd"
      gksu.rootMethod = "su"
      VMCI_CONFED = "yes"
      VMBLOCK_CONFED = "yes"
      VSOCK_CONFED = "yes"
      NETWORKING = "yes"
      player.product.version = "${version}"
      product.version = "${version}"
      product.buildNumber = "${build}"
      product.name = "VMware Workstation"
      workstation.product.version = "${version}"
    EOF
  '';
}
