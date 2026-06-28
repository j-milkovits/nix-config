{ config
, pkgs
, ...
}: {
  imports = [
    ../../modules/base
    ../../modules/desktop

    ./hardware-configuration.nix # include results of hardware scan
  ];

  networking.hostName = "desktop";

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html)
  system.stateVersion = "25.05";
}
