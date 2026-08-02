{ ...
}: {
  imports = [
    ../../modules/base
    ../../modules/desktop

    ./disko.nix # root disk layout
    ./hardware-configuration.nix # include results of hardware scan

    # host-specific
    ./sops.nix
    ./wireguard.nix
  ];

  networking.hostName = "laptop";

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # no swap partition, so no hibernate - compressed swap in ram instead
  zramSwap.enable = true;

  # noctalia owns idle, lock and screen-off, but it does not touch the lid switch
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore"; # an external screen is the point of docking
  };

  # before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html)
  system.stateVersion = "26.05";
}
