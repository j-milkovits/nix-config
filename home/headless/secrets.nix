{ pkgs
, ...
}: {
  # secrets management (sops-nix workflow)
  home.packages = with pkgs; [
    age # encryption backend, age-keygen
    sops # edit encrypted files, updatekeys
    ssh-to-age # derive a host's age key from its ssh host key
  ];
}
