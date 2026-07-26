{ pkgs
, ...
}: {
  # will be installed in all systems on root level
  environment.systemPackages = with pkgs; [
    curl
    git
    # ssh forwards the client's TERM, kitty's is unknown to a bare host
    kitty.terminfo
    vim
    wget
  ];
}
