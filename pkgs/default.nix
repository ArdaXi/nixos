final: prev:
let
  lua-overrides = (lua-final: lua-prev: {
    luv = lua-prev.luv.override ({
      version = "1.34.1-1";
      src = final.fetchurl {
        url = https://luarocks.org/luv-1.34.1-1.src.rock;
        sha256 = "044cyp25xn35nj5qp1hx04lfkzrpa6adhqjshq2g7wvbga77p1q0";
      };
    });
  });
	pythonOverrides = {
    packageOverrides = python-final: python-prev: {
      bleach = python-prev.bleach.overridePythonAttrs (old: {
        propagatedBuildInputs = old.propagatedBuildInputs ++ [ python-final.packaging ];
        doCheck = false;
        checkPhase = "";
      });
		websockets = python-prev.websockets.overridePythonAttrs (_: {
        doCheck = false;
        checkPhase = "";
      });
    };
  };
in
rec {
  sickbeard = final.callPackage ./sickbeard.nix {};
  hplip = final.callPackage ./hplip.nix {};

  python3 = prev.python3.override pythonOverrides;
  python38 = prev.python38.override pythonOverrides;

  inverter-exporter = final.callPackage ./inverter {};

  pg_prometheus = final.callPackage ./pg-prometheus.nix {};

  prometheus-postgresql = final.callPackage ./prometheus-postgresql-adapter/default.nix {};

  wxGTK31 = prev.wxGTK31.overrideAttrs (oldAttrs : rec {
    name = "wxwidgets-${version}";
    version = "3.1.2";
    src = final.fetchFromGitHub {
        owner = "wxWidgets";
        repo = "wxWidgets";
        rev = "v${version}";
        sha256 = "0gfdhb7xq5vzasm7s1di39nchv42zsp0dmn4v6knzb7mgsb107wb";
    };
    configureFlags = [ "--disable-precomp-headers" "--enable-mediactrl" "--enable-unicode" "--with-opengl" ];
  });

  darcs = prev.darcs.overrideScope (final: prev: { Cabal = final.Cabal_2_2_0_1; });

#  libreoffice-fresh = prev.libreoffice-fresh.override {
#    libreoffice = prev.libreoffice-fresh.libreoffice.override {
#      poppler = final.callPackage ./poppler.nix {};
#    };
#  };

  calibre = final.libsForQt5.callPackage ./calibre.nix {};
}
