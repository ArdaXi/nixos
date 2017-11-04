self: super: {
  openconnect = self.callPackage ./openconnect.nix {};
  networkmanager_openconnect = self.callPackage ./networkmanager_openconnect.nix {};
  sickbeard = self.callPackage ./sickbeard.nix {};
  sickrage = self.callPackage ./sickrage.nix {};
}
