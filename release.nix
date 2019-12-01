with import <nixpkgs/lib>;
let
  pkgs = import <nixpkgs> {};
  configFor = modules: (import <nixpkgs/nixos/lib/eval-config.nix> {
    system = "x86_64-linux";
    modules = modules;
  }).config.system.build;
  configForMachine = machineName:
    configFor [(./machines + "/${machineName}.nix")];
  targetForMachine = machineName: (configForMachine machineName).toplevel;
  allTests = (import <nixpkgs/nixos/tests/all-tests.nix> rec {
    system = "x86_64-linux";
    pkgs = import <nixpkgs> { inherit system; };
    callTest = t: hydraJob t.test;
  });
in rec
  {
    machines = genAttrs [
      "cic"
      "hiro"
    ] targetForMachine;
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
      inherit (allTests) acme firefox grafana hydra i3wm matrix-synapse
        nextcloud postgresql prometheus;
    };
  }
