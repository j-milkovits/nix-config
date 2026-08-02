{ ...
}: {
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;

    # no defaultCommand, the built in walker already includes hidden files
    # and skips .git, and it is faster than shelling out to fd
    defaultOptions = [ "--height 40%" "--layout=reverse" "--border" ];
  };
}
