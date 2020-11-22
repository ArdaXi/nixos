{ ... }:

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  users.users.ardaxi.extraGroups = [ "docker" ];
}
