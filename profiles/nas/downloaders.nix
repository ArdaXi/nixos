{ pkgs, lib, ... }:
{
  nixpkgs.config.permittedInsecurePackages = [ "p7zip-16.02" ]; # needed for sabnzbd

  services = {
    transmission = {
      enable = true;
      settings.rpc-port = 9091;
    };
    nzbget.enable = true;
    sonarr.enable = true;
    radarr.enable = true;
  };

  systemd.services.nzbget = {
    confinement = {
      enable = true;
      packages = with pkgs; [ unrar p7zip ];
    };
    serviceConfig = {
      UMask = lib.mkForce "0000";
      BindPaths = [
        "/media"
        "/var/lib/nzbget"
      ];
      BindReadOnlyPaths = [ "/etc/resolv.conf" ];
    };
  };
}
