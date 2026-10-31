{ nix4nvchad
, pkgs
, ...
}: {
  imports = [
    nix4nvchad.homeManagerModules.default
  ];

  programs.nvchad = {
    enable = true;

    extraPackages = with pkgs; [
      # LSPs
      lua-language-server
      vscode-langservers-extracted # html, css, json
      tailwindcss-language-server
      typescript-language-server
      pyright
      rust-analyzer
      jdt-language-server

      # Formatters
      stylua
      prettier
      ruff # formats and sorts imports, replaces black and isort
      rustfmt
      nixpkgs-fmt
    ];
  };
}
