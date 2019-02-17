with import <nixpkgs/lib>;
let
  pkgs = import <nixpkgs> {};
  configFor = modules: (import <nixpkgs/nixos/lib/eval-config.nix> {
    system = "x86_64-linux";
    modules = modules;
  }).config.system.build;
  configForMachine = machineName:
    configFor [(./machines + "/${machineName}.nix")];
  targetsForProfile = profileName: {
    iso = (configFor [
      (./profiles + "/${profileName}-iso.nix")
    ]).isoImage;
  };
in rec
  {
    profiles = genAttrs [
      "desktop"
    ] targetsForProfile;
  }
