{ nix4nvchad
, pkgs
, ...
}: {
  imports = [
    nix4nvchad.homeManagerModule
  ];

  programs.nvchad = {
    enable = true;

    extraPackages = with pkgs; [
      # LSPs
      lua-language-server
      vscode-langservers-extracted   # html, css, json
      tailwindcss-language-server
      typescript-language-server
      pyright
      rust-analyzer
      jdt-language-server

      # Formatters
      stylua
      prettier
      isort
      black
      rustfmt
      nixpkgs-fmt
    ];
  };
}
