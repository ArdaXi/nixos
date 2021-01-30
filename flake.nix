{
  description = "A highly structured configuration database.";

  inputs = {
    nixos.url = "nixpkgs/master";
    home = {
      url = "github:rycee/home-manager/bqv-flakes";
      inputs.nixpkgs.follows = "nixos";
    };
  };

  outputs = inputs@{ self, home, nixos }:
    let
      inherit (builtins) attrNames attrValues readDir mapAttrs;
      inherit (nixos) lib;
      inherit (lib) removeSuffix recursiveUpdate genAttrs filterAttrs hydraJob;
      inherit (utils) pathsToImportedAttrs;

      utils = import ./lib/utils.nix { inherit lib; };

      system = "x86_64-linux";

      pkgImport = system: pkgs:
        import pkgs {
          inherit system;
          overlays = attrValues self.overlays;
          config = { allowUnfree = true; };
        };

      pkgsetFor = system: {
        osPkgs = pkgImport system nixos;
        pkgs = pkgImport system nixos;
      };

      pkgset = pkgsetFor system;

    in
    with pkgset;
    {
      nixosConfigurations = import ./hosts (
        recursiveUpdate inputs {
          inherit lib pkgset system utils;
        }
      ) // import ./aarch64 (
        recursiveUpdate inputs {
          inherit lib utils;
          system = "aarch64-linux";
          pkgset = pkgsetFor "aarch64-linux";
        }
      );

      hydraJobs = {
        hosts = mapAttrs (n: v: hydraJob v.config.system.build.toplevel) self.nixosConfigurations;
      };

      devShell."${system}" = import ./shell.nix {
        inherit pkgs;
      };

      overlay = import ./pkgs;

      overlays =
        let
          overlayDir = ./overlays;
          fullPath = name: overlayDir + "/${name}";
          overlayPaths = map fullPath (attrNames (readDir overlayDir));
        in
        pathsToImportedAttrs overlayPaths;

      packages."${system}" =
        let
          packages = self.overlay osPkgs osPkgs;
          overlays = lib.filterAttrs (n: v: n != "pkgs") self.overlays;
          overlayPkgs =
            genAttrs
              (attrNames overlays)
              (name: (overlays."${name}" osPkgs osPkgs)."${name}");
        in
        recursiveUpdate packages overlayPkgs;

      nixosModules =
        let
          # binary cache
          cachix = import ./cachix.nix;
          cachixAttrs = { inherit cachix; };

          # modules
          moduleList = import ./modules/list.nix;
          modulesAttrs = pathsToImportedAttrs moduleList;

          # profiles
          profilesList = import ./profiles/list.nix;
          profilesAttrs = { profiles = pathsToImportedAttrs profilesList; };

        in
        recursiveUpdate
          (recursiveUpdate cachixAttrs modulesAttrs)
          profilesAttrs;

      templates.flk.path = ./.;
      templates.flk.description = "flk template";

      defaultTemplate = self.templates.flk;
    };
}
