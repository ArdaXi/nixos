{ ... }:
{
  nixpkgs.config.permittedInsecurePackages = [ "p7zip-16.02" ]; # needed for sabnzbd

  services = {
    sabnzbd.enable = true;
    sickrage.enable = true;
    transmission = {
      enable = true;
      port = 9091;
    };
  };

  systemd.services.sabnzbd = {
    confinement.enable = true;
    serviceConfig = {
      BindPaths = [
        "/var/lib/sabnzbd"
        "/media"
      ];
      BindReadOnlyPaths = [
        "/etc/resolv.conf"
      ];
    };
  };
}
