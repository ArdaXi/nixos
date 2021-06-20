{ stdenv
, buildPythonApplication
, lib
, python
, fetchurl
, fetchFromGitHub
, lame
, mpv-unwrapped
, libpulseaudio
, pyqtwebengine
, decorator
, beautifulsoup4
, sqlalchemy
, pyaudio
, requests
, markdown
, matplotlib
, pytest
, glibcLocales
, nose
, jsonschema
, setuptools
, send2trash
, CoreAudio
  # This little flag adds a huge number of dependencies, but we assume that
  # everyone wants Anki to draw plots with statistics by default.
, plotsSupport ? true
  # manual
, asciidoc
, protoc
, protobuf
, stringcase
, black
, flask
, flask-cors
, waitress
, pyqt5
, perl
, nodePackages
, fetchzip
, coreutils
, callPackage
}:

let
  # when updating, also update rev-manual to a recent version of
  # https://github.com/ankitects/anki-docs
  # The manual is distributed independently of the software.
  version = "2.1.44";
  sha256-pkg = "sha256-wkyHqsBCs6yAPqImaQkXMKSLV17p2ZOWctRsr20yh7U=";
  rev-manual = "515132248c0ccb1e0ddbaf44fbe9bdb67a24742f";
  sha256-manual = "1hrhs20cd6sbkfjxc45q8clmfai5nwwv27lhgnv46x1qnwimj8np";

  anki-bin = fetchzip {
    url = "https://github.com/ankitects/anki/releases/download/${version}/anki-${version}-linux.tar.bz2";
    sha256 = "sha256-Nb+zlusyj0JiiR49p1y4qtB+pJX05LO3la5VP7XN32M=";
  };

  rsbridge = callPackage ./rsbridge.nix {
    protobuf = protoc;
  };

  manual = stdenv.mkDerivation {
    pname = "anki-manual";
    inherit version;
    src = fetchFromGitHub {
      owner = "ankitects";
      repo = "anki-docs";
      rev = rev-manual;
      sha256 = sha256-manual;
    };
    phases = [ "unpackPhase" "patchPhase" "buildPhase" ];
    nativeBuildInputs = [ asciidoc ];
    patchPhase = ''
      # rsync isnt needed
      # WEB is the PREFIX
      # We remove any special ankiweb output generation
      # and rename every .mako to .html
      sed -e 's/rsync -a/cp -a/g' \
          -e "s|\$(WEB)/docs|$out/share/doc/anki/html|" \
          -e '/echo asciidoc/,/mv $@.tmp $@/c \\tasciidoc -b html5 -o $@ $<' \
          -e 's/\.mako/.html/g' \
          -i Makefile
      # patch absolute links to the other language manuals
      sed -e 's|https://apps.ankiweb.net/docs/|link:./|g' \
          -i {manual.txt,manual.*.txt}
      # there’s an artifact in most input files
      sed -e '/<%def.*title.*/d' \
          -i *.txt
      mkdir -p $out/share/doc/anki/html
    '';
  };

in
buildPythonApplication rec {
  pname = "anki";
  inherit version;

  src = fetchurl {
    urls = [
      "https://github.com/ankitects/anki/archive/${version}.tar.gz"
      # "https://github.com/ankitects/anki/releases/download/${version}/${pname}-${version}-linux.tar.bz2"
      # "https://apps.ankiweb.net/downloads/current/${pname}-${version}-source.tgz"
      # "https://apps.ankiweb.net/downloads/current/${name}-source.tgz"
      # "http://ankisrs.net/download/mirror/${name}.tgz"
      # "http://ankisrs.net/download/mirror/archive/${name}.tgz"
    ];
    sha256 = sha256-pkg;
  };

  outputs = [ "out" "doc" "man" ];

  propagatedBuildInputs = [
    pyqtwebengine
    sqlalchemy
    beautifulsoup4
    send2trash
    pyaudio
    requests
    decorator
    markdown
    jsonschema
    setuptools
    protobuf
    flask
    flask-cors
    waitress
  ]
  ++ lib.optional plotsSupport matplotlib
  ++ lib.optional stdenv.isDarwin [ CoreAudio ]
  ;

  checkInputs = [ pytest glibcLocales nose ];

  nativeBuildInputs = [ pyqtwebengine.wrapQtAppsHook stringcase black pyqt5 perl ];
  buildInputs = [ lame mpv-unwrapped libpulseaudio ];

  patches = [
    # Disable updated version check.
    ./no-version-check.patch
  ];

  # Anki does not use setup.py
  dontBuild = true;

  postPatch = ''
    # hitting F1 should open the local manual
    substituteInPlace pylib/anki/consts.py \
      --replace 'HELP_SITE = "https://docs.ankiweb.net/#/"' \
                'HELP_SITE = "${manual}/share/doc/anki/html/manual.html"'
  '';

  # UTF-8 locale needed for testing
  LC_ALL = "en_US.UTF-8";

  # tests fail
  doCheck = false;

  installPhase = ''
    pp=$out/lib/${python.libPrefix}/site-packages

    mkdir -p $out/bin
    mkdir -p $out/share/applications
    mkdir -p $doc/share/doc/anki
    mkdir -p $man/share/man/man1
    mkdir -p $out/share/mime/packages
    mkdir -p $out/share/pixmaps
    mkdir -p $pp

    cat > $out/bin/anki <<EOF
    #!${python}/bin/python
    import aqt
    aqt.run()
    EOF

    chmod 755 $out/bin/anki

    cat > pylib/anki/buildinfo.txt <<EOF
    STABLE_VERSION ${version}
    STABLE_BUILDHASH nogit
    EOF

    rm qt/aqt/hooks_gen.py qt/aqt/colors.py pylib/anki/hooks_gen.py
    PYTHONPATH=$PWD:$PWD/pylib/tools:$PYTHONPATH ${python}/bin/python qt/tools/genhooks_gui.py qt/aqt/hooks_gen.py
    ${python}/bin/python qt/tools/extract_sass_colors.py ts/sass/_vars.scss qt/aqt/colors.py
    PYTHONPATH=$PWD:$PWD/pylib/tools:$PYTHONPATH ${python}/bin/python pylib/tools/genhooks.py pylib/anki/hooks_gen.py

    cp ${./fluent.proto} rslib/fluent.proto
    ${protoc}/bin/protoc --python_out=. rslib/backend.proto rslib/fluent.proto
    cp rslib/*_pb2.py pylib/anki/_backend/

    rm pylib/anki/_backend/generated.py
    cp ${./generated-stub.py} pylib/anki/_backend/generated.py
    chmod 777 pylib/anki/_backend/generated.py

    cp ${rsbridge}/lib/librsbridge.so pylib/anki/_backend/rsbridge.so

    substituteInPlace pylib/anki/_backend/genbackend.py --replace "pylib.anki._backend.backend_pb2" "backend_pb2"

    PYTHONPATH=$PWD:$PWD/pylib:$PWD/qt:$PYTHONPATH ${python}/bin/python pylib/anki/_backend/genbackend.py > pylib/anki/_backend/generated.py

    for filename in qt/aqt/forms/*.ui; do
      ${python}/bin/python qt/aqt/forms/build_ui.py $filename qt/aqt/forms/$(${coreutils}/bin/basename $filename .ui).py
    done
    ${python}/bin/python qt/aqt/forms/build_rcc.py qt/aqt/forms/icons.qrc qt/aqt/forms/icons_rc.py

    rm -rf qt/aqt/data/web

    cp -v qt/linux/anki.desktop $out/share/applications/
    cp -v README* LICENSE* $doc/share/doc/anki/
    cp -v qt/linux/anki.1 $man/share/man/man1/
    cp -v qt/linux/anki.xml $out/share/mime/packages/
    cp -v qt/linux/anki.{png,xpm} $out/share/pixmaps/
    # cp -rv locale $out/share/
    cp -rv pylib/anki qt/aqt $pp/
    cp -rv ${anki-bin}/bin/aqt_data/web $pp/aqt/data/web

    mkdir -p $pp/aqt/data/locale
    cat ftl/qt/*.ftl > $pp/aqt/data/locale/template.ftl

    # copy the manual into $doc
    cp -r ${manual}/share/doc/anki/html $doc/share/doc/anki
  '';

  # now wrapPythonPrograms from postFixup will add both python and qt env variables
  dontWrapQtApps = true;

  preFixup = ''
    makeWrapperArgs+=(
      "''${qtWrapperArgs[@]}"
      --prefix PATH ':' "${lame}/bin:${mpv-unwrapped}/bin"
    )
  '';

  passthru = {
    inherit manual;
  };

  meta = with lib; {
    homepage = "https://apps.ankiweb.net/";
    description = "Spaced repetition flashcard program";
    longDescription = ''
      Anki is a program which makes remembering things easy. Because it is a lot
      more efficient than traditional study methods, you can either greatly
      decrease your time spent studying, or greatly increase the amount you learn.

      Anyone who needs to remember things in their daily life can benefit from
      Anki. Since it is content-agnostic and supports images, audio, videos and
      scientific markup (via LaTeX), the possibilities are endless. For example:
      learning a language, studying for medical and law exams, memorizing
      people's names and faces, brushing up on geography, mastering long poems,
      or even practicing guitar chords!
    '';
    license = licenses.agpl3Plus;
    platforms = platforms.mesaPlatforms;
    maintainers = with maintainers; [ oxij Profpatsch ];
  };
}
