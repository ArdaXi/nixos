with import <nixpkgs/lib>;
let
  pkgs = import <nixpkgs> {
    overlays = (import ./overlays);
  };
  configFor = system: modules: (import <nixpkgs/nixos/lib/eval-config.nix> {
    system = system;
    modules = modules;
    pkgs = pkgs;
  }).config.system.build;
  configForMachine = system: machineName:
    configFor system [(./machines + "/${machineName}.nix")];
  targetForMachine = system: machineName: (configForMachine system machineName).toplevel;
in rec
  {
    inherit pkgs;
    machines = genAttrs [
      "cic"
      "hiro"
    ] (targetForMachine "x86_64-linux");
    armMachines = genAttrs [
      "librarian"
    ] (targetForMachine "armv6l-linux");
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
  }
