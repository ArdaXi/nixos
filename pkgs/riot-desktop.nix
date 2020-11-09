{ stdenv, electron, riot-web }:

stdenv.mkDerivation rec {
  name = "riot-desktop-${version}";
  version = riot-web.version;

  buildCommand = ''
    mkdir -p $out/bin
    cat > $out/bin/riot-desktop <<EOF
    #!${stdenv.shell}
    exec ${electron}/bin/electron ${riot-web}/index.html "\$@"
    EOF
    chmod 755 $out/bin/riot-desktop
  '';
}
