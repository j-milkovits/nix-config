{ lib,
...
}: {
  # p10k config
  home.file.".p10k.zsh".source = ./.p10k.zsh;

  programs.zsh = {
    enable = true;

    autocd = true;
    # cdpath = [ ];

    # envExtra = [ ];

    # shellAliases = { };

    initContent = let
      # zshConfigEarlyInit = lib.mkOrder 500 "";
      # zshConfigBeforeCompInit = lib.mkOrder 550 "";
      # zshConfig = lib.mkOrder 1000 "";
      zshConfigLast = lib.mkOrder 1500 ''
        [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

        if uwsm check may-start; then
            exec uwsm start hyprland-uwsm.desktop
        fi
      '';
    in
      lib.mkMerge [zshConfigLast];


    prezto = {
      enable = true;

      editor = {
        keymap = "vi";
        promptContext = true;
      };

      pmodules = [
        "environment"
        "terminal"
        "editor"
        "history"
        "directory"
        "spectrum"
        "utility"
        "completion"
        "syntax-highlighting"
        "history-substring-search"
        "autosuggestions"
        "prompt"
        # "fasd"
        # "ssh"
        # "tmux"
      ];

      prompt = {
        theme = "powerlevel10k";
      };

      # add to .zpreztorc
      # extraConfig = [ ];
    };
  };
}
