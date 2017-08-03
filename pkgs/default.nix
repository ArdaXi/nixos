with import <nixpkgs> {};
rec
{
  libgtop11dotnet = callPackage ./libgtop11dotnet.nix {};
#  geth = callPackage ./geth.nix {};
#  mist = callPackage ./mist.nix { geth = geth; };
}
