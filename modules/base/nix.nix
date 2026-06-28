{ lib
, ...
}: {
  # allow specification of additional substituters
  # nix.settings.trusted-users = [username];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];

    # appended to the default substituters (cache.nixos.org), not replacing them
    extra-substituters = [
      # community packages (home-manager, nix4nvchad, NUR, ...)
      "https://nix-community.cachix.org"
      # unfree packages that Hydra refuses to build (bambu-studio, ...)
      "https://nixpkgs-unfree.cachix.org"
    ];
    extra-trusted-public-keys = [
      # from https://app.cachix.org/cache/nix-community
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      # from https://app.cachix.org/cache/nixpkgs-unfree
      "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
    ];
  };

  nixpkgs.config.allowUnfree = lib.mkDefault true;

  # garbage collection
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };
}
