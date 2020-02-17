self: super:
let
  pinned = (import (self.fetchFromGitHub {
    owner = "nixos";
    repo = "nixpkgs";
    rev = "8a9733361e05d162e80d534543bdf79b27036e5e";
    sha256 = "0y18n2y00ljsnxkmas66d179i43nl0b4qhjzj6wd5389j6rhs356";
  }) {});
  lua-overrides = (lua-self: lua-super: {
    luv = lua-super.luv.override ({
      src = self.fetchurl {
        url = https://luarocks.org/luv-1.34.1-1.src.rock;
        sha256 = "044cyp25xn35nj5qp1hx04lfkzrpa6adhqjshq2g7wvbga77p1q0";
      };
    });
  });

in
rec {
  sickbeard = self.callPackage ./sickbeard.nix {};
  #sickrage = self.callPackage ./sickrage.nix {};
  riot-desktop = self.callPackage ./riot-desktop.nix {};

  pcsclite = self.callPackage ./pcsclite/default.nix {};

  ccid = pinned.ccid;

  yubikey-manager = pinned.yubikey-manager;

  tahoelafs = self.callPackage ./tahoelafs/default.nix {}; # Fix backup command

#  rustNightly = self.callPackage ./rust-nightly.nix {};

  hplip = self.callPackage ./hplip.nix {};

  python3 = super.python3.override {
    packageOverrides = python-self: python-super: {
      bleach = python-super.bleach.overridePythonAttrs (_: {
        doCheck = false;
        checkPhase = "";
      });
    };
  };

  python38 = super.python38.override {
    packageOverrides = python-self: python-super: {
      bleach = python-super.bleach.overridePythonAttrs (_: {
        doCheck = false;
        checkPhase = "";
      });
    };
  };

  lua = super.lua.override { packageOverrides = lua-overrides; };
  lua5 = super.lua5.override { packageOverrides = lua-overrides; };
  lua5_1 = super.lua5_1.override { packageOverrides = lua-overrides; };
  lua5_2 = super.lua5_2.override { packageOverrides = lua-overrides; };
  lua5_2_compat = super.lua5_2_compat.override { packageOverrides = lua-overrides; };
  lua5_3 = super.lua5_3.override { packageOverrides = lua-overrides; };
  luajit = super.luajit.override { packageOverrides = lua-overrides; };
  luajit_2_0 = super.luajit_2_0.override { packageOverrides = lua-overrides; };
  luajit_2_1 = super.luajit_2_1.override { packageOverrides = lua-overrides; };

  hydra = self.callPackage ./hydra.nix {};

  inverter-exporter = self.callPackage ./inverter {};

  pg_prometheus = self.callPackage ./pg-prometheus.nix {};

  prometheus-postgresql = self.callPackage ./prometheus-postgresql-adapter/default.nix {};

  wxGTK31 = super.wxGTK31.overrideAttrs (oldAttrs : rec {
    name = "wxwidgets-${version}";
    version = "3.1.2";
    src = self.fetchFromGitHub {
        owner = "wxWidgets";
        repo = "wxWidgets";
        rev = "v${version}";
        sha256 = "0gfdhb7xq5vzasm7s1di39nchv42zsp0dmn4v6knzb7mgsb107wb";
    };
    configureFlags = [ "--disable-precomp-headers" "--enable-mediactrl" "--enable-unicode" "--with-opengl" ];
  });

  prusa-slicer = self.callPackage ./prusa-slicer.nix { wxGTK30 = wxGTK31; };
}
