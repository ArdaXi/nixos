{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    libu2f-host yubikey-manager yubikey-manager-qt
    gnupg pass-wayland browserpass pinentry_qt tomb
  ];

  services = {
    udev.extraRules = ''
      DRIVER=="snd_hda_intel", ATTR{power/control}="on"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0406", GROUP="wheel", TAG+="uaccess"
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
  };

  programs.ssh.startAgent = true;
}
