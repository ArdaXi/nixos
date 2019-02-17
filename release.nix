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
  targetsForProfile = profileName: {
#    ova = (configFor [
#      (./profiles + "/${profileName}-ova.nix")
#    ]).virtualBoxOVA;
    vm = (configFor [
      (./profiles + "/${profileName}-vm.nix")
    ]).vm;
  };
in rec
  {
    machines = genAttrs [
      "cic"
      "hiro"
    ] targetForMachine;
#    profiles = genAttrs [
#      "desktop"
#    ] targetsForProfile;
    channel = pkgs.releaseTools.channel {
      constituents = [ machines.cic machines.hiro ];
      name = "nixpkgs";
      src = <nixpkgs>;
    };
  }
