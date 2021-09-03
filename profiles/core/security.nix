{ config, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.pam_u2f ];

  security.doas.enable = true;

  security.pam.services.doas.u2fAuth = true;
}
