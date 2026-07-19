{ pkgs
, ...
}: {
  # network debugging, most homelab problems turn out to be network problems
  home.packages = with pkgs; [
    dnsutils # dig, nslookup
  ];
}
