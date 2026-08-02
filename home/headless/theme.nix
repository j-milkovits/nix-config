{ catppuccin
, ...
}: {
  imports = [ catppuccin.homeModules.catppuccin ];

  # one flavour for every program that has a catppuccin module and is enabled here
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "lavender";
  };
}
