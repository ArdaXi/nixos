with import <nixpkgs/lib>;
let
  pkgs = import <nixpkgs> {};
  configFor = modules: (import <nixpkgs/nixos/lib/eval-config.nix> {
    system = "armv6l-linux";
    modules = modules;
  }).config.system.build;
  configForMachine = machineName:
    configFor [(./machines + "/${machineName}.nix")];
  targetForMachine = machineName: (configForMachine machineName).toplevel;
  sdForMachine = machineName: (configForMachine machineName).sdImage;
  allTests = (import <nixpkgs/nixos/tests/all-tests.nix> rec {
    system = "x86_64-linux";
    pkgs = import <nixpkgs> { inherit system; overlays = (import ./overlays); };
    callTest = t: hydraJob t.test;
  });
in rec
  {
    machines = genAttrs [
      "librarian"
    ] targetForMachine;
    sdImages = genAttrs [
      "librarian"
    ] sdForMachine;
    nixpkgs = pkgs.releaseTools.channel {
      constituents = [ machines.cic machines.hiro ];
      name = "nixpkgs";
      src = <nixpkgs>;
    };
    nixos-config = pkgs.releaseTools.channel {
      constituents = [machines.cic machines.hiro ];
      name = "nixos-config";
      src = ./.;
    };
    tests = {
      inherit (allTests) firefox grafana i3wm matrix-synapse
        prometheus;
      inherit (allTests.postgresql) postgresql_9_6;

#      hydra = allTests.hydra.nixUnstable;
    };
  }
