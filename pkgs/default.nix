final: prev:
let
#  pinned = (import (final.fetchFromGitHub {
#    owner = "nixos";
#    repo = "nixpkgs";
#    rev = "8a9733361e05d162e80d534543bdf79b27036e5e";
#    sha256 = "0y18n2y00ljsnxkmas66d179i43nl0b4qhjzj6wd5389j6rhs356";
#  }) {});
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
#  sabnzbd = final.callPackage ./sabnzbd.nix {};
  #sickrage = final.callPackage ./sickrage.nix {};
#  riot-desktop = final.callPackage ./riot-desktop.nix {};

#  pcsclite = final.callPackage ./pcsclite/default.nix {};

#  ccid = pinned.ccid;

#  yubikey-manager = pinned.yubikey-manager;

#  tahoelafs = final.callPackage ./tahoelafs/default.nix {}; # Fix backup command

#  rustNightly = final.callPackage ./rust-nightly.nix {};

  hplip = final.callPackage ./hplip.nix {};

  python3 = prev.python3.override pythonOverrides;
  python38 = prev.python38.override pythonOverrides;

#  lua = prev.lua.override { packageOverrides = lua-overrides; };
#  lua5 = prev.lua5.override { packageOverrides = lua-overrides; };
#  lua5_1 = prev.lua5_1.override { packageOverrides = lua-overrides; };
#  lua5_2 = prev.lua5_2.override { packageOverrides = lua-overrides; };
#  lua5_2_compat = prev.lua5_2_compat.override { packageOverrides = lua-overrides; };
#  lua5_3 = prev.lua5_3.override { packageOverrides = lua-overrides; };
#  luajit = prev.luajit.override { packageOverrides = lua-overrides; };
#  luajit_2_0 = prev.luajit_2_0.override { packageOverrides = lua-overrides; };
#  luajit_2_1 = prev.luajit_2_1.override { packageOverrides = lua-overrides; };

  #hydra = final.callPackage ./hydra.nix {};

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

  prusa-slicer = final.callPackage ./prusa-slicer.nix { };

  darcs = prev.darcs.overrideScope (final: prev: { Cabal = final.Cabal_2_2_0_1; });

#  jicofo = prev.jicofo or final.callPackage ./jitsi/jicofo.nix {};
#  jitsi-meet = prev.jitsi-meet or final.callPackage ./jitsi/jitsi.nix {};
#  jitsi-videobridge = prev.jitsi-videobridge or final.callPackage ./jitsi/jvb.nix {};

  libreoffice-fresh = prev.libreoffice-fresh.override {
    libreoffice = prev.libreoffice-fresh.libreoffice.override {
      poppler = final.callPackage ./poppler.nix {};
    };
  };

#  hydra-unstable = (prev.hydra-unstable.overrideAttrs (oldAttrs: rec {
#    version = "2020-07-09";
#    src = final.fetchFromGitHub {
#      owner = "NixOS";
#      repo = "hydra";
#      rev = "48678df8b67d562f16a88dbbc2e3878e53635932";
#      sha256 = "sha256-tyozceL84P5nArLVlnHL/6lQooAib/CdfwdLQhrljAM=";
#    };
#  })).override {
#    nix = (final.nixFlakes.override {
#      name = "nix-2.4pre07072020_1ab9da9";
#    }).overrideAttrs (_: rec {
#      src = final.fetchFromGitHub {
#        owner = "NixOS";
#        repo = "nix";
#        rev = "1ab9da915422405452118ebb17b88cdfc90b1e10";
#        sha256 = "sha256-M801IExREv1T9F+K6YcCFERBFZ3+6ShwzAR2K7xvExA=";
#      };
#    });
#  };

  calibre = final.libsForQt5.callPackage ./calibre.nix {};
}
