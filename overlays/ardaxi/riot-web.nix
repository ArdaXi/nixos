{ stdenv, fetchurl, fetchgit, python2, utillinux, runCommand, writeTextFile, nodejs, darwin }:

let
  nodeEnv = import ./node-env.nix {
    inherit stdenv python2 utillinux runCommand writeTextFile nodejs;
    libtool = if stdenv.isDarwin then darwin.cctools else null;
  };
in
(import ./node-packages.nix {
  inherit fetchurl fetchgit;
  inherit nodeEnv;
}).package
