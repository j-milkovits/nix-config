{ pkgs
, config
, ...
}: {
  programs.kitty = {
    enable = true;

    themeFile = "Catppuccin-Mocha";

    enableGitIntegration = true;
    shellIntegration.enableZshIntegration = true;

    font = {
      name = "FiraCode Nerd Font Mono";
      size = 12;
    };

    # environment = [ ];

    # keybindings = [ ]; 

    # settings = {};

  };

}
