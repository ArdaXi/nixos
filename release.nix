{ nixpkgs ? <nixpkgs> }:
let
  nixpkgsConfig = {
    allowUnfree = true;
    permittedInsecurePackages = [ 
       "aspnetcore-runtime-wrapped-6.0.36"
       "dotnet-sdk-6.0.428"
    ];
  };

  nixos = import nixpkgs { overlays = []; config = nixpkgsConfig; };
  master = nixos;


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
}
