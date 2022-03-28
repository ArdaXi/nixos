{ config, pkgs, ... }:

{
  systemd.services.languagetool = {
    description = "Languagetool";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.languagetool}/bin/languagetool-http-server --port 9111 --public --allow-origin --premiumAlways";
      DynamicUser = true;
      LockPersonality = true;
      NoNewPrivileges = true;
      MemoryDenyWriteExecute = true;
      ProtectSystem = "strict";
      ProtectClock = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      RestrictAddressFamilies = [ "AF_NETLINK" "AF_INET6" "AF_INET" ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      RemoveIPC = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectProc = "invisible";
      PrivateMounts = true;
      PrivateTmp = true;
      PrivateDevices = true;
      PrivateUsers = true;
      ProcSubset = "pid";
    };
  };
}
