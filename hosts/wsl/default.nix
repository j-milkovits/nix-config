{ nixos-wsl
, ...
}: {
  imports = [
    nixos-wsl.nixosModules.default

    # the base layer by file: no ssh.nix, so no sshd and none of the fleet's keys, no storage, no firewall
    # this box reaches nothing of the others and nothing of theirs lands on it
    ../../modules/base/user-group.nix
    ../../modules/base/nix.nix
    ../../modules/base/i18n.nix
    ../../modules/base/packages.nix
    ../../modules/dev
    ../../modules/wsl
  ];

  # the other hosts get this from their hardware scan, wsl has none
  nixpkgs.hostPlatform = "x86_64-linux";

  networking.hostName = "wsl";

  # before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html)
  system.stateVersion = "26.05";
}
