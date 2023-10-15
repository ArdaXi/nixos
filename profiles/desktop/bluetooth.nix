{ pkgs, ... }:

{
  services.blueman.enable = true;

  hardware = {
    bluetooth.enable = true;
    pulseaudio = {
      extraModules = [];
      extraConfig = ''
        load-module module-switch-on-connect
        load-module module-bluetooth-policy auto_switch=2
      '';
    };
  };
}
