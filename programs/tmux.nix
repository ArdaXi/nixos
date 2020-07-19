{ config, pkgs, ... }:

let
  tmux-yank = pkgs.fetchFromGitHub {
    owner = "tmux-plugins";
    repo = "tmux-yank";
    rev = "648005db64d9bf3c4650eff694ecb6cf3e42b0c8";
    sha256 = "1zg9k8yk1iw01vl8m44w4sv20lln4l0lq9dafc09lxmgxm9dllj4";
  };
in
{
  environment = {
    systemPackages = [ pkgs.tmux pkgs.xsel ];

    etc."tmux.conf".text = ''
      set -gw activity-action none
      set -g  allow-rename off
      set -g  base-index 1
      set -g  default-shell "${pkgs.zsh}/bin/zsh"
      set -gs default-terminal screen-256color
      set -s  escape-time 0
      set -gw mode-keys vi
      set -gw monitor-activity on
      set -g  mouse on
      set -gw pane-active-border-style fg=brightwhite
      set -gw pane-base-index 1
      set -gw pane-border-format ' #{pane_current_command} '
      set -gw pane-border-status top
      set -g  prefix C-a
      set -g  renumber-windows on
      set -g  status-left ""
      set -g  status-position top
      set -g  status-right ""
      set -ga status-right " #{?client_prefix, #[bright]#{prefix}#[nobright] ,}"
      set -ga status-right ' #(echo \#"{last_exit_status_#{pane_id}}") '
      set -ga status-right ' #(cd #{pane_current_path} && ${pkgs.zsh}/bin/zsh -c "print -P %%~") '
      set -ga status-right '#(head="$(${pkgs.git}/bin/git -C #{pane_current_path} rev-parse --abbrev-ref HEAD 2>/dev/null)" && echo " $head ")'
      set -g  status-right-length 200
      set -g  status-style bg=default,fg=white
      set -gw window-status-activity-style fg=brightwhite
      set -gw window-status-bell-style fg=brightcyan
      set -gw window-status-current-format '#W'
      set -gw window-status-current-style bright
      set -gw window-status-format '#W'
      set -gw window-status-separator '  '

      bind -n   F1  select-window -t :1
      bind -n   F2  select-window -t :2
      bind -n   F3  select-window -t :3
      bind -n   F4  select-window -t :4
      bind -n   F5  select-window -t :5
      bind -n   F6  select-window -t :6
      bind -n   F7  select-window -t :7
      bind -n   F8  select-window -t :8
      bind -n   F9  select-window -t :9
      bind -n   F10 select-window -t :10
      bind -n   F11 select-window -t :11
      bind -n   F12 select-window -t :12
      bind -n S-F1  send-keys F1
      bind -n S-F2  send-keys F2
      bind -n S-F3  send-keys F3
      bind -n S-F4  send-keys F4
      bind -n S-F5  send-keys F5
      bind -n S-F6  send-keys F6
      bind -n S-F7  send-keys F7
      bind -n S-F8  send-keys F8
      bind -n S-F9  send-keys F9
      bind -n S-F10 send-keys F10
      bind -n S-F11 send-keys F11
      bind -n S-F12 send-keys F12

      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      bind -n C-l send-keys C-l \; run-shell "sleep 0.3" \; clear-history

      bind-key -T copy-mode-vi v send-keys -X begin-selection

      bind '"' split-window -v -c '#{pane_current_path}'
      bind  %  split-window -h -c '#{pane_current_path}'

      bind C-a send-prefix

      unbind C-b

      set-hook -g after-select-pane "refresh-client -S"
      set-hook -g alert-activity "refresh-client -S"

      set -g @override_copy_command '${pkgs.xsel}/bin/xsel -i --clipboard'

      run-shell ${tmux-yank}/yank.tmux
    '';
  };
}
