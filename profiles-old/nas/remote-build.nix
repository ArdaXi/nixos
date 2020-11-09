{ config, pkgs, lib, ... }:

{
  users.extraUsers.nixbuild = {
    name = "nixbuild";
    shell = pkgs.bashInteractive;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILRmMpqZs45J4+Bl0LrRpjWvM/EOz1CBtWiBWyrEK9iS"
    ];
  };
}
