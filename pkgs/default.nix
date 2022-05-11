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
#  hplip = final.callPackage ./hplip.nix {};

  innernet = prev.innernet.overrideAttrs (_: {
    doCheck = false;
    checkPhase = "";
  });

#  udisks2 = prev.udisks2.overrideAttrs (_: {
#    doCheck = false;
#    checkPhase = "";
#  });

  python3 = prev.python3.override pythonOverrides;
  python38 = prev.python38.override pythonOverrides;

  inverter-exporter = final.callPackage ./inverter {};

  pg_prometheus = final.callPackage ./pg-prometheus.nix {};

  prometheus-postgresql = final.callPackage ./prometheus-postgresql-adapter/default.nix {};

#  darcs = prev.darcs.overrideScope (final: prev: { Cabal = final.Cabal_2_2_0_1; });

  mudlet = final.libsForQt5.callPackage ./mudlet.nix { lua = final.lua5_1; };

  nix-hydra = final.nixVersions.nix_2_6 or final.nix;
  hydra-unstable = (prev.hydra-unstable.overrideAttrs (oldAttrs: {
    patches = oldAttrs.patches or [] ++ [
      ./hydra-no-restrict.patch
    ];
  })).override { nix = nix-hydra; };

#  calibre = final.libsForQt5.callPackage ./calibre.nix {};
#  anki-bin = final.python3Packages.callPackage ./anki/anki.nix {
#    inherit (final.darwin.apple_sdk.frameworks) CoreAudio;
#    protoc = final.protobuf;
#  };

#  qemu-patched = if prev.qemu.version != "6.1.0" then prev.qemu else (prev.qemu.overrideAttrs (oldAttrs: {
#    patches = oldAttrs.patches ++ [ (final.fetchpatch {
#      url = "https://gitlab.com/qemu-project/qemu/-/commit/eb94846280df3f1e2a91b6179fc05f9890b7e384.diff";
#      sha256 = "05cw0n3bgysq0d20c5y5cilqv1i3famqfrvw55vnfnc2nxqsbplx";
#    })];
#  }));
}
