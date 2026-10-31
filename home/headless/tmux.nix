{ config
, lib
, pkgs
, ...
}:
let
  # the catppuccin palette as hex, the same source the ports render from (theme.nix)
  palette = (lib.importJSON "${config.catppuccin.sources.palette}/palette.json").${config.catppuccin.flavor}.colors;
  c = name: palette.${name}.hex;
  accent = c config.catppuccin.accent;
in
{
  # the catppuccin tmux plugin is loud, powerline blocks for what only says where you are - the bar below is text
  catppuccin.tmux.enable = false;

  programs.tmux = {
    enable = true;
    prefix = "C-Space";
    keyMode = "vi";
    mouse = true;
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 50000;
    terminal = "tmux-256color";
    clock24 = true;

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

      # the bar: transparent, the session in the accent, the current window underlined, the clock on the right
      set -g status-style "fg=${c "subtext0"},bg=default"
      set -g status-left-length 100
      set -g status-left "#[fg=${accent},bold]  #S #[fg=${c "surface1"},nobold]│ "
      set -g status-right "#[fg=${c "overlay1"}]%a %d %b  %H:%M "
      set -g window-status-format " #I #W "
      set -g window-status-current-format "#[fg=${accent},bold,underscore] #I #W #[nounderscore]"
      set -g window-status-separator ""
      # the same restraint for what tmux draws itself
      set -g message-style "fg=${c "text"},bg=default"
      set -g mode-style "fg=${c "base"},bg=${c "blue"}"
      set -g pane-border-style "fg=${c "surface0"}"
      set -g pane-active-border-style "fg=${c "overlay0"}"
    '';
  };
}
