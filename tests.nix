{ nixpkgs ? <nixpkgs> }:
let
  nixos = import nixpkgs { overlays = []; };
  master = nixos;

  inherit (builtins) attrValues removeAttrs;
  inherit (nixos) lib;
  inherit (lib) recursiveUpdate hydraJob;

  utils = import ./lib/utils.nix { inherit lib; };

  inherit (utils) pathsToImportedAttrs recImport;

  system = "x86_64-linux";

  pkgs = import nixpkgs {
    inherit system;
    overlays = attrValues (pathsToImportedAttrs [ ./overlays/pkgs.nix ]);
    config = { allowUnfree = true; };
  };

  allTests = (import (nixpkgs + "/nixos/tests/all-tests.nix") {
    inherit system pkgs;
    callTest = t: hydraJob t.test;
  });

in rec {
  tests = {
    inherit (allTests) acme firefox grafana hydra login nginx nzbget
      openssh prometheus signal-desktop sudo sway wireguard;

    inherit (allTests.postgresql) postgresql_14;

    zfsStable = allTests.zfs.stable;
  };
}
