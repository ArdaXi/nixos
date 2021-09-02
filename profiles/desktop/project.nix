{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.teams
  ];
}
