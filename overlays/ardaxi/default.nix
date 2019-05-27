self: super:
let
  pinned = (import (self.fetchFromGitHub {
    owner = "nixos";
    repo = "nixpkgs";
    rev = "8a9733361e05d162e80d534543bdf79b27036e5e";
    sha256 = "0y18n2y00ljsnxkmas66d179i43nl0b4qhjzj6wd5389j6rhs356";
  }) {});
in
rec {
  sickbeard = self.callPackage ./sickbeard.nix {};
  sickrage = self.callPackage ./sickrage.nix {};
  riot-desktop = self.callPackage ./riot-desktop.nix {};

  pcsclite = self.callPackage ./pcsclite/default.nix {};

  ccid = pinned.ccid;

  yubikey-manager = pinned.yubikey-manager;

  tahoelafs = self.callPackage ./tahoelafs/default.nix {}; # Fix backup command

#  rustNightly = self.callPackage ./rust-nightly.nix {};

  hplip = self.callPackage ./hplip.nix {};

#  python = super.python.override {
#    packageOverrides = python-self: python-super: {
#      nevow = python-super.nevow.overridePythonAttrs (_: {
#        checkPhase = "";
#      });
#    };
#  };

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
