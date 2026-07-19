{ pkgs
, config
, claude-code-nix
, ...
}: {
  programs.claude-code = {
    enable = true;
    package = claude-code-nix.packages.${pkgs.system}.default;
    settings = {
      theme = "dark";
      includeCoAuthoredBy = false;
    };
  };
}
