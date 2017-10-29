{config, pkgs, lib, ...}:
{
  imports = [
    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>

    ../profiles/default.nix
  ];

  boot.supportedFilesystems = [ "zfs" ];

  # Enable SSH in the boot process.
  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];

  networking.hostId = "567f8775";
  networking.hostName = "cic-live";
}

