{ username
, ...
}: {
  imports = [
    ./bat.nix
    ./btop
    ./claude-code.nix
    ./disk.nix
    ./fzf.nix
    ./git.nix
    ./lazygit.nix
    ./network.nix
    ./nvim
    ./tealdeer.nix
    ./tools.nix
    ./zoxide.nix
    ./zsh
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";

    # you can update Home Manager without changing this value
    stateVersion = "25.05";
  };
}
