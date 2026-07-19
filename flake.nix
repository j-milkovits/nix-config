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

    # secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix4nvchad, ... }@inputs:
    let
      vars = import ./vars;

      # one host = one folder under hosts/, everything else is identical
      mkHost = hostName:
        nixpkgs.lib.nixosSystem {
          # ensure that all submodules receive the non-default arguments
          specialArgs = vars;

          modules = [
            ./hosts/${hostName}

            # secrets management, defines the sops.* options
            inputs.sops-nix.nixosModules.sops

            # integrate home-manager as NixOS module
            # this ensures that home-manager config will be deployed automatically on nixos-rebuild
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;

                # pass arguments to home.nix
                extraSpecialArgs = inputs // vars;
                users."${vars.username}" = import ./hosts/${hostName}/home.nix;
              };
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        desktop = mkHost "desktop";
        server = mkHost "server";

        # laptop = mkHost "laptop";
        # wsl = mkHost "wsl";
      };
    };
}
