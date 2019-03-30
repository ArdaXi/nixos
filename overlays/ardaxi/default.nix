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
#  openconnect = self.callPackage ./openconnect.nix {};
#  networkmanagerapplet = self.callPackage ./network-manager-applet.nix {};
#  networkmanager_openconnect = self.callPackage ./networkmanager_openconnect.nix {};
  networkmanager_wireguard = self.callPackage ./networkmanager_wireguard.nix {};
  sickbeard = self.callPackage ./sickbeard.nix {};
  sickrage = self.callPackage ./sickrage.nix {};
  matrix-synapse = self.callPackage ./matrix-synapse.nix {};
  riot-desktop = self.callPackage ./riot-desktop.nix {};

  pcsclite = self.callPackage ./pcsclite/default.nix {};

  ccid = pinned.ccid;

  yubikey-manager = pinned.yubikey-manager;

  haskellPackages = pinned.haskellPackages;
  taffybar = pinned.taffybar;

  tahoelafs = self.callPackage ./tahoelafs.nix {};
  rustNightly = self.callPackage ./rust-nightly.nix {};

  hplip = self.callPackage ./hplip.nix {};

  python = super.python.override {
    packageOverrides = python-self: python-super: {
      nevow = python-super.nevow.overridePythonAttrs (_: {
        checkPhase = "";
      });
    };
  };

  hydra = super.hydra.overrideAttrs (oldAttrs: rec {
    version = "2019-02-01";
    src = super.fetchFromGitHub {
      owner = "NixOS";
      repo = "hydra";
      rev = "8b5948f4cf12424c04df67a6eb136c9846fb2cfd";
      sha256 = "0ldk3li394vykl9c4v9bs8pir05pmad24s0rx9bzqgz569zfj2iv";
    };
  });

  inverter-exporter = self.callPackage ./inverter {};

  pg_prometheus = self.callPackage ./pg-prometheus.nix {};

  prometheus-postgresql = self.callPackage ./prometheus-postgresql-adapter/default.nix {};
}
