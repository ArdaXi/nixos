{ config, pkgs, ... }:

{
  services.bitlbee = {
    enable = true;
    authMode = "Closed";
  };

  services.taskserver.enable = true;

  networking.firewall.allowedTCPPorts = [ 53589 ];

  systemd.user.services.irc-session = {
    enable = true;
    description = "Persistent tmux session running irssi";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "forking";
      ExecStart = "${pkgs.tmux}/bin/tmux new-session -d -s main -n irssi ${pkgs.irssi}/bin/irssi";
      ExecStop = "${pkgs.tmux}/bin/tmux kill-session -t main";
    };
  };

  environment.systemPackages = with pkgs; [
    (writeScriptBin "irc" "${tmux}/bin/tmux attach-session -t main")
  ];
}
