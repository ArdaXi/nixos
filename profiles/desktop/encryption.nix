{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    libu2f-host yubikey-manager
    gnupg pass browserpass pinentry_qt tomb
  ];

  services = {
    udev.extraRules = ''
      DRIVER=="snd_hda_intel", ATTR{power/control}="on"
    '';
#      SUBSYSTEM=="usb", ATTR{idVendor}=="1d50", ATTR{idProduct}=="cc15", MODE="0600", OWNER="ardaxi",
#      GROUP="ardaxi"
#      SUBSYSTEM=="usb", ATTR{idVendor}=="1d50", ATTR{idProduct}=="6089", MODE="0600", OWNER="ardaxi",
#      GROUP="ardaxi"
#      SUBSYSTEM=="usb", ATTR{idVendor}=="1050", ATTR{idProduct}=="0406", MODE="0600", OWNER="ardaxi",
#      GROUP="ardaxi"

    pcscd.enable = true;
  };

  programs.gnupg.agent = {
    enable = true;
    enableBrowserSocket = true;
    enableExtraSocket = true;
    enableSSHSupport = true;
  };
}
