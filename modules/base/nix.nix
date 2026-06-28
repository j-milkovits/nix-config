{ lib
, ...
}: {
  # allow specification of additional substituters
  # nix.settings.trusted-users = [username];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    # substituters = ["https://cache.nixos.org"];
  };

  nixpkgs.config.allowUnfree = lib.mkDefault true;

  # garbage collection
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };
}
