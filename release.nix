with import <nixpkgs/lib>;
let
  configForMachine = machine: import <nixpkgs/nixos/lib/eval-config.nix> {
    system = "x86_64-linux";
    modules = [
      (./machines + "/${machine}.nix")
    ];
  };
  nixosForMachine = machine: (configForMachine machine).config.system.build.toplevel;
  machines = genAttrs [
    "cic"
    "hiro"
  ] nixosForMachine;
in
  machines
