{ pkgs, ... }:

{
  services.blueman.enable = true;

  hardware = {
    bluetooth.enable = true;
    pulseaudio = {
      extraModules = [ pkgs.pulseaudio-modules-bt ];
      extraConfig = ''
        load-module module-switch-on-connect
        load-module module-bluetooth-policy auto_switch=2
      '';
    };
  };

  nixpkgs.config.packageOverrides = pkgs: {
    bluez = pkgs.bluez5;
  };
}
