with import <nixpkgs> {};
{
  tahoelafs = callPackage ./tahoe-lafs.nix {
    inherit (pythonPackages) twisted foolscap simplejson nevow zfec
      pycryptopp sqlite3 darcsver setuptoolsTrial setuptoolsDarcs
      numpy pyasn1 mock zope_interface;
  };
}
