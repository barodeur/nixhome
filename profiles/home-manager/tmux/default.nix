{ ... }:

{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    keyMode = "vi";
    terminal = "screen-256color";
    shortcut = "a";
    historyLimit = 100000;

    tmuxinator.enable = true;

    extraConfig = ''
      bind-key ^D detach-client
      set -g renumber-windows on

      bind-key v split-window -h -p 50 -c "#{pane_current_path}"
      bind-key ^V split-window -h -p 50 -c "#{pane_current_path}"
      bind-key s split-window -p 50 -c "#{pane_current_path}"
      bind-key ^S split-window -p 50 -c "#{pane_current_path}"

      # Pane resize in all four directions using vi bindings.
      # Can use these raw but I map them to shift-ctrl-<h,j,k,l> in iTerm.
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Smart pane switching with awareness of vim splits.
      # Source: https://github.com/christoomey/vim-tmux-navigator
      # is_vim='echo "#{pane_current_command}" | grep -iqE "(^|\/)g?(view|n?vim?x?)(diff)?$"'
      bind -n C-h if-shell "$is_vim" "send-keys C-h" "select-pane -L"
      bind -n C-j if-shell "$is_vim" "send-keys C-j" "select-pane -D"
      bind -n C-k if-shell "$is_vim" "send-keys C-k" "select-pane -U"
      bind -n C-l if-shell "$is_vim" "send-keys C-l" "select-pane -R"
      bind -n 'C-\' if-shell "$is_vim" "send-keys 'C-\\'" "select-pane -l"
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # No escape time for vi mode
      set -sg escape-time 0

      # New windows/pane in $PWD
      bind c new-window -c "#{pane_current_path}"

      # force a reload of the config file
      unbind r
      bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"

      set-option -g status-style bg=default

      set -g @plugin 'tmux-plugins/tpm'
      set -g @plugin 'tmux-plugins/tmux-sensible'
      set -g @plugin 'tmux-plugins/tmux-resurrect'
      set -g @plugin 'tmux-plugins/tmux-continuum'
      set -g @plugin 'tmux-plugins/tmux-yank'
      set -g @plugin 'tmux-plugins/tmux-open'
      set -g @plugin 'janoamaral/tokyo-night-tmux'

      run -b '~/.tmux/plugins/tpm/tpm'
    '';
  };
}
