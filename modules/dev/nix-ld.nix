{ ...
}: {
  # loader so binaries that tools download can be accessed (like normal linux)
  programs.nix-ld.enable = true;
}
