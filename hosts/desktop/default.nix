{ config
, pkgs
, ...
}: {
  imports = [
    ../../modules/system.nix
    ../../modules/nvidia.nix
    ../../modules/hyprland.nix

    ./hardware-configuration.nix # include results of hardware scan
  ];

  networking = {
    hostName = "desktop";
    networkmanager.enable = true; # enable networking
    # defaultGateway = "";
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # before changing this value read the documentation for this option 
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html)
  system.stateVersion = "25.05";
}
