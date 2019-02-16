let
  pkgs = import <nixpkgs> {};

  jobs = import ./release.nix;

in
  {
    channel = pkgs.releaseTools.channel {
      constituents = [ jobs.machines.cic jobs.machines.hiro ];
      name = "nixpkgs";
      src = <nixpkgs>;
    };
  }
