{
  users.users.ardaxi = {
    uid = 1000;
    name = "ardaxi";
    group = "ardaxi";
    extraGroups = [ "users" "wheel" "networkmanager" "audio" "adbusers" "libvirtd" "vboxusers" ];
    home = "/home/ardaxi";
    createHome = true;
    shell = "/run/current-system/sw/bin/zsh";
    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGF+jT+vAfFpVuylZbfp2ZInVHo4J31xlG1ytGoqsgT/AAAABHNzaDo= ardaxi@hiro"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC9L+dgqEWlz1HCAFvOo2WMcxXUCVZjEENrSCHEHdGKx ardaxi@hiro"
    ];
    isNormalUser = true;
  };

  users.groups.ardaxi.gid = 1000;

  programs.zsh.enable = true;
}
