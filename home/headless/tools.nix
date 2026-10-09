{ pkgs
, ...
}: {
  # general purpose cli tooling, unconfigured
  home.packages = with pkgs; [
    fd # find replacement
    jq # json processor
    just # runs the recipes in the repo justfile
    nixpkgs-fmt # the formatter `just fmt` calls
    yq-go # yaml processor
    ripgrep # grep replacement
    tree
  ];
}
