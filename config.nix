with import <nixpkgs/lib>;
let
  pkgs = import <nixpkgs> {};
  configFor = modules: (import <nixpkgs/nixos/lib/eval-config.nix> {
    system = "x86_64-linux";
    modules = modules;
  });
  configForMachine = machineName:
    configFor [(./machines + "/${machineName}.nix")];
in rec
  {
    machines = genAttrs [
      "cic"
      "hiro"
    ] configForMachine;
  }
