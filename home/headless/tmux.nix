{ pkgs
, ...
}: {
  # the flavour comes with catppuccin.enable in theme.nix
  programs.tmux = {
    enable = true;
    prefix = "C-Space";
    keyMode = "vi";
    mouse = true;
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 50000;
    terminal = "tmux-256color";

    plugins = with pkgs.tmuxPlugins; [
      # copies to the system clipboard from copy mode
      yank
    ];

    extraConfig = ''
      set -g status-position top
      set -g renumber-windows on
      # yazi's image previews reach kitty through tmux
      set -g allow-passthrough on
      # new panes and windows open where the current one is
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
      # picks up a switched config without leaving the session
      bind r source-file ~/.config/tmux/tmux.conf \; display "config reloaded"

      # ctrl + arrows move between panes, and between neovim splits inside a pane, as one thing - the neovim half
      # is in nvim/config/lua/mappings.lua - arrows and not hjkl, those sit on three rows of a colemak board
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
      bind -n C-Left  if-shell "$is_vim" 'send-keys C-Left'  'select-pane -L'
      bind -n C-Down  if-shell "$is_vim" 'send-keys C-Down'  'select-pane -D'
      bind -n C-Up    if-shell "$is_vim" 'send-keys C-Up'    'select-pane -U'
      bind -n C-Right if-shell "$is_vim" 'send-keys C-Right' 'select-pane -R'
    '';
  };
}
