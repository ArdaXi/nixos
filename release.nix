let
  nixos = import <nixpkgs> {};
  master = nixos;

  inherit (builtins) attrValues removeAttrs;
  inherit (nixos) lib;
  inherit (lib) recursiveUpdate hydraJob;

  utils = import ./lib/utils.nix { inherit lib; };

  inherit (utils) pathsToImportedAttrs recImport;

  system = "x86_64-linux";

  pkgs = import <nixpkgs> {
    inherit system;
    overlays = attrValues (pathsToImportedAttrs [ ./overlays/pkgs.nix ]);
    config = { allowUnfree = true; };
  };

  allTests = (import <nixpkgs/nixos/tests/all-tests.nix> {
    inherit system pkgs;
    callTest = t: hydraJob t.test;
  });

  config = hostName: (hydraJob
    (import <nixpkgs/nixos/lib/eval-config.nix> {
      inherit system;

      modules =
        let
          core = import "${toString ./.}/profiles/core";
          global = {
            networking.hostName = hostName;

            nixpkgs = { pkgs = pkgs; };
          };
          local = import "${toString ./.}/hosts/${hostName}.nix";
          flakeModules = attrValues (pathsToImportedAttrs (import ./modules/list.nix));
        in flakeModules ++ [ core global local ];
    }).config.system.build.toplevel);

in rec {
  machines = recImport {
    dir = ./hosts;
    _import = config;
  };

  tests = {
    inherit (allTests) acme bat firefox grafana hydra login nginx nzbget
      openssh prometheus signal-desktop sudo sway wireguard zfs;

    inherit (allTests.postgresql) postgresql_12;
  };
}
