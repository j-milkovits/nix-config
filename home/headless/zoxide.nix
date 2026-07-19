{ ...
}: {
  # cd replacement that learns your most used directories, jump with `z <part-of-path>`
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
