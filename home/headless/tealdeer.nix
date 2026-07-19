{ ...
}: {
  # tldr pages, community maintained examples instead of full man pages
  programs.tealdeer = {
    enable = true;

    settings = {
      display = {
        compact = true; # drop the blank lines between examples
        use_pager = false; # pages are short, paging just costs an extra keypress
      };

      # catppuccin mocha
      style = {
        description.foreground = { rgb = { r = 205; g = 214; b = 244; }; }; # text
        command_name = {
          foreground = { rgb = { r = 203; g = 166; b = 247; }; }; # mauve
          bold = true;
        };
        example_text.foreground = { rgb = { r = 137; g = 180; b = 250; }; }; # blue
        example_code.foreground = { rgb = { r = 166; g = 227; b = 161; }; }; # green
        example_variable = {
          foreground = { rgb = { r = 250; g = 179; b = 135; }; }; # peach
          italic = true;
        };
      };
    };
  };
}
