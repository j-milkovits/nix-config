{ pkgs
, ...
}: {
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
      # ctrl + hjkl crosses tmux panes and neovim splits alike, the neovim half sits in nvim/config/lua/plugins
      vim-tmux-navigator
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
    '';
  };
}
