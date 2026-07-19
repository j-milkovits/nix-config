{ pkgs
, ...
}: {
  # general purpose cli tooling, unconfigured
  home.packages = with pkgs; [
    fd # find replacement
    jq # json processor
    yq-go # yaml processor
    ripgrep # grep replacement
    tree
  ];
}
