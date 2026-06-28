{ pkgs
, username
, ...
}: {
  # define a user account
  # set password with `passwd`
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # setup zsh for all users
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
}
