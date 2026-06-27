{ username
, ...
}: {
  home = {
    inherit username;
    homeDirectory = "/home/${username}";

    # you can update Home Manager without changing this value
    stateVersion = "25.05";
  };
}
