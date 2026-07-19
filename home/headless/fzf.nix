{ ...
}: {
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;

    # no defaultCommand, the built in walker already includes hidden files
    # and skips .git, and it is faster than shelling out to fd
    defaultOptions = [ "--height 40%" "--layout=reverse" "--border" ];

    # catppuccin mocha
    colors = {
      "bg+" = "#313244";
      "fg+" = "#cdd6f4";
      hl = "#f38ba8";
      "hl+" = "#f38ba8";
      header = "#f38ba8";
      info = "#cba6f7";
      marker = "#f5e0dc";
      pointer = "#f5e0dc";
      prompt = "#cba6f7";
      spinner = "#f5e0dc";
    };
  };
}
