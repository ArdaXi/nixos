with import <nixpkgs/lib>;

(import <nixpkgs/nixos/lib/eval-config.nix> {
    system = "aarch64-linux";
    pkgs = (import <nixpkgs> {
      system = "x86_64-linux";
      crossSystem = {
        config = "aarch64-unknown-linux-gnu";
      };
    });
    modules = [
      ./profiles/default-sd.nix
    ];
}).config.system.build.sdImage
