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
    iso = (configFor [(./profiles + "/${profileName}-iso.nix")]).isoImage;
    netboot = let
        configEvaled = import <nixpkgs/nixos/lib/eval-config.nix> {
          system = "x86_64-linux";
          modules = [(./profiles + "/${profileName}-netboot.nix")];
        };
        build = configEvaled.config.system.build;
        kernelTarget = configEvaled.pkgs.stdenv.hostPlatform.platform.kernelTarget;
      in
        pkgs.symlinkJoin {
          name = "netboot";
          paths = [
            build.netbootRamdisk
            build.kernel
            build.netbootIpxeScript
          ];
          postBuild = ''
            mkdir -p $out/nix-support
            echo "file ${kernelTarget} ${build.kernel}/${kernelTarget}" >> $out/nix-support/hydra-build-products
            echo "file initrd ${build.netbootRamdisk}/initrd" >> $out/nix-support/hydra-build-products
            echo "file ipxe ${build.netbootIpxeScript}/netboot.ipxe" >> $out/nix-support/hydra-build-products
          '';
          preferLocalBuild = true;
        };
  };
in rec
  {
    profiles = genAttrs [
      "desktop"
    ] targetsForProfile;
  }
