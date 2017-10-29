self: super: {
  openconnect = self.callPackage ./openconnect.nix {};
  networkmanager_openconnect = self.callPackage ./networkmanager_openconnect.nix {};
}
