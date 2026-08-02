{ pkgs
, config
, ...
}: {
  programs.kitty = {
    enable = true;

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
