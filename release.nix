{ nixpkgs ? <nixpkgs> }:
let
  nixos = import nixpkgs { overlays = []; };
  master = nixos;

  nixpkgsConfig = {
    allowUnfree = true;
    permittedInsecurePackages = [ 
       "aspnetcore-runtime-wrapped-6.0.36"
       "dotnet-sdk-6.0.428"
    ];
  };

  inherit (builtins) attrValues removeAttrs;
  inherit (nixos) lib;
  inherit (lib) recursiveUpdate hydraJob;

  utils = import ./lib/utils.nix { inherit lib; };

  inherit (utils) pathsToImportedAttrs recImport;

  system = "x86_64-linux";

  pkgs = import nixpkgs {
    inherit system;
    overlays = attrValues (pathsToImportedAttrs [ ./overlays/pkgs.nix ]);
    config = nixpkgsConfig;
  };

  config = hostName: (hydraJob
    (import (nixpkgs + "/nixos/lib/eval-config.nix") {
      inherit system;

      modules =
        let
          core = import "${toString ./.}/profiles/core";
          global = {
            networking.hostName = hostName;

            nixpkgs = { pkgs = pkgs; config = nixpkgsConfig };
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
}
