let
  release = import <nixpkgs/nixos/release.nix>;
in {
  iso_graphical = release.forAllSystems (system: release.makeIso {
    module = ./machines/livecd.nix;
    type = "graphical";
    inherit system;
  });
}
