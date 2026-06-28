{ pkgs
, ...
}: {
  # will be installed in all systems on root level
  environment.systemPackages = with pkgs; [
    curl
    git
    vim
    wget
  ];
}
