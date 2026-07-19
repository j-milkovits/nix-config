{ pkgs
, config
, ...
}: {
  programs.btop = {
    enable = true;
    themes = {
      catppuccin_mocha = ./themes/catppuccin_mocha.theme;
    };
    settings = {
      color_theme = "catppuccin_mocha";
      theme_background = false;
    };
  };
}
