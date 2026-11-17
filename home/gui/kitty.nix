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

    settings = {
      # kitty restores the last closed window's maximize state, hyprland owns window state instead
      remember_window_size = false;
    };

  };

}
