{ lib, pkgs, ... }:

{
  # This is an incredibly ugly hack...
  options = {
    nix.extraOptions = lib.mkOption {
      apply = builtins.replaceStrings ["gc-check-reachability"] ["#gc-check-reachability"];
    };
  };

  config = {
    services = {
      hydra = {
        enable = true;
        hydraURL = "https://hydra.street.ardaxi.com";
        notificationSender = "hydra@localhost";
        useSubstitutes = true;
        extraConfig = "max_output_size = 4294967296";
        package = pkgs.hydra-unstable;
      };

      nix-serve = {
        enable = true;
        port = 3001;
        secretKeyFile = "/etc/nix/signing-key.sec";
      };
    };

    users.users.nixbuild = {
      name = "nixbuild";
      group = "nixbuild";
      shell = pkgs.bashInteractive;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILRmMpqZs45J4+Bl0LrRpjWvM/EOz1CBtWiBWyrEK9iS"
      ];
      isSystemUser = true;
    };

    users.groups.nixbuild = {};

    nix.allowedUsers = [ "hydra" "hydra-www" "@hydra" "nix-serve" ];
  };
}
