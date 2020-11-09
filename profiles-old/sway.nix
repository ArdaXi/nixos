{ config, pkgs, ... }:

{
  programs.sway = {
    enable = true;
    extraSessionCommands = ''
      ${pkgs.networkmanagerapplet}/bin/nm-applet &
      ${pkgs.xsettingsd}/bin/xsettingsd &
      export XKB_DEFAULT_LAYOUT=us
      export XKB_DEFAULT_OPTIONS=compose:caps
    '';
  };

  users.extraUsers.ardaxi.extraGroups = [ "sway" ];

  services.kmscon = {
    enable = true;
    hwRender = true;
    extraConfig = ''
      font-size=10
      font-dpi=192
    '';
  };

  environment.systemPackages = [ pkgs.xwayland ];
}
