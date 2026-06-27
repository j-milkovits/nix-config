{ username
, ...
}: {
  home = {
    inherit username;
    homeDirectory = "/home/${username}";

    # you can update Home Manager without changing this value
    stateVersion = "25.05";
  };

  # let Home Manager install and manage itself
  programs.home-manager.enable = true;
}
