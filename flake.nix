{
  description = "NixOS system configuration of j-milkovits";

  inputs = {
    # official NixOS package source, using nixos's 26.05 branch by default
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    # nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      # keep inputs.nixpkgs of home-manager consistent with inputs.nixpkgs of flake
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NvChad
    nvchad-starter = {
      url = "path:./home/headless/nvim/config";
      flake = false; # don't treat this folder as a flake
    };
    nix4nvchad = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nvchad-starter.follows = "nvchad-starter";
    };

    # Claude Code
    claude-code-nix.url = "github:sadjow/claude-code-nix";
  };

  outputs = { self, nixpkgs, home-manager, nix4nvchad, ... }@inputs:
    let
      vars = import ./vars;
    in
    {
      # could rewrite this to a function (see: https://github.com/notusknot/dotfiles-nix/blob/main/flake.nix)
      nixosConfigurations = {
        desktop =
          let
            specialArgs = vars;
          in
          nixpkgs.lib.nixosSystem {
            # ensure that all submodules receive the non-default arguments
            inherit specialArgs;

            modules = [
              ./hosts/desktop

              # integrate home-manager as NixOS module
              # this ensures that home-manager config will be deployed automatically on nixos-rebuild
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;

                  # pass arguments to home.nix
                  extraSpecialArgs = inputs // specialArgs;
                  users."${vars.username}" = import ./hosts/desktop/home.nix;
                };
              }
            ];
          };

        server =
          let
            specialArgs = vars;
          in
          nixpkgs.lib.nixosSystem {
            inherit specialArgs;

            modules = [
              ./hosts/server

              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;

                  extraSpecialArgs = inputs // specialArgs;
                  users."${vars.username}" = import ./hosts/server/home.nix;
                };
              }
            ];
          };

        # laptop =
        # wsl =
      };
    };
}
