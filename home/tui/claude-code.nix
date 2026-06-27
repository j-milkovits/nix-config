
{ pkgs
, config
, ...
}: {
  programs.claude-code = {
    enable = true;
    settings = {
      theme = "dark";
      includeCoAuthoredBy = false;
    };
  };
}
