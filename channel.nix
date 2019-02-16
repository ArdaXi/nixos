let
  pkgs = import <nixpkgs> {};

  jobs = import ./release.nix;

in
  pkgs.releaseTools.channel {
    constituents = [ jobs.machines.cic jobs.machines.hiro ];
    name = "ardaxi";
    src = ./.;
  }
