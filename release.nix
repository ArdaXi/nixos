with import <nixpkgs/lib>;
let
  configFor = modules: (import <nixpkgs/nixos/lib/eval-config.nix> {
    system = "x86_64-linux";
    modules = modules;
  }).config.system.build;
  configForMachine = machineName:
    configFor [(./machines + "/${machineName}.nix")];
  targetForMachine = machineName: (configForMachine machineName).toplevel;
  targetsForProfile = profileName: {
    ova = (configFor [
      (./profiles + "/${profileName}-ova.nix")
    ]).virtualBoxOVA;
    vm = (configFor [
      (./profiles + "/${profileName}-vm.nix")
    ]).vm;
  };
in
  {
    machines = genAttrs [
      "cic"
      "hiro"
    ] targetForMachine;
    profiles = genAttrs [
      "desktop"
    ] targetsForProfile;
  }
