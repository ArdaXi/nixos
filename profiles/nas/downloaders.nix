{ pkgs, lib, ... }:
{
  services = {
    transmission = {
      enable = true;
      settings.rpc-port = 9091;
      webHome = pkgs.flood-for-transmission;
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
