{ pkgs, ... }:

{
  hardware.pulseaudio = {
    package = pkgs.pulseaudioFull;
    enable = true;
    support32Bit = true;
  };

  environment.systemPackages = with pkgs; [ mpv alsaUtils pavucontrol ];
}
