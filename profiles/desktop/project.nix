{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.teams
  ];

  virtualisation.virtualbox.host.enable = true;
}
