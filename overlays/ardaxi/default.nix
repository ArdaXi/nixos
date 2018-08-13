self: super: {
  openconnect = self.callPackage ./openconnect.nix {};
#  networkmanagerapplet = self.callPackage ./network-manager-applet.nix {};
  networkmanager_openconnect = self.callPackage ./networkmanager_openconnect.nix {};
  sickbeard = self.callPackage ./sickbeard.nix {};
  sickrage = self.callPackage ./sickrage.nix {};
  matrix-synapse = self.callPackage ./matrix-synapse.nix {};
  riot-desktop = self.callPackage ./riot-desktop.nix {};

  rustNightly = self.callPackage (self.fetchFromGitHub {
     owner = "solson";
     repo = "rust-nightly-nix";
     rev = "7081bacc88037d9e218f62767892102c96b0a321";
     sha256 = "0dzqmbwl2fkrdhj3vqczk7fqah8q7mfn40wx9vqavcgcsss63m8p";
  }) {};
}
