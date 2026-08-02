{ ...
}: {
  # cat replacement with syntax highlighting, also used as the pager elsewhere
  programs.bat = {
    enable = true;

    config = {
      style = "numbers,changes,header";
    };
  };
}
