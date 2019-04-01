with import <nixpkgs/lib>;
let
  nixpkgs = import <nixpkgs> {};
  pkgs = nixpkgs.pkgsMusl // {
# inherit (nixpkgs) broken;
  };
  configFor = modules: (import <nixpkgs/nixos/lib/eval-config.nix> {
    system = "x86_64-linux";
    modules = modules;
    pkgs = pkgs;
  }).config.system.build;
  configForMachine = machineName:
    configFor [(./machines + "/${machineName}.nix")];
  targetForMachine = machineName: (configForMachine machineName).toplevel;
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
  }
