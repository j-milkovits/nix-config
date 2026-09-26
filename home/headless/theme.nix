{ catppuccin
, pkgs
, ...
}: {
  imports = [ catppuccin.homeModules.catppuccin ];

  # one flavour for every program that has a catppuccin module and is enabled here
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "lavender";

    # the ports render their templates with whiskers at build time
    # the flake's own whiskers follows our nixpkgs and has no cache hit, nixpkgs' copy is on cache.nixos.org
    sources = catppuccin.packages.${pkgs.stdenv.hostPlatform.system}.overrideScope (_: _: {
      whiskers = pkgs.catppuccin-whiskers;
    });
  };
}
