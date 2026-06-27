{ nix4nvchad
, ...
}: {
  imports = [
    nix4nvchad.homeManagerModule
  ];

  programs.nvchad.enable = true;
}
