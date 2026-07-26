{ ...
}: {
  # containers become systemd units, so they roll back with the generation
  virtualisation = {
    podman = {
      enable = true;
      # podman compatible with docker commands
      dockerCompat = true;
      # images pile up on every tag bump
      autoPrune.enable = true;
    };

    oci-containers = {
      backend = "podman";

      # personal finance
      containers.actual = {
        image = "ghcr.io/actualbudget/actual:sha-3b2f89e@sha256:2d95396914c62212230d3cc7dd9f7bd9eba2da46696e5e4d4a6dfac4bdbaa5a1";
        ports = [ "5006:5006" ];
        volumes = [ "/mnt/data/actual:/data" ];
        environment.TZ = "Europe/Berlin";
      };
    };
  };

  # nofail lets the boot continue without the data disk and podman creates a missing bind source itself
  # ensures that drive is mounted
  systemd.services.podman-actual.unitConfig.RequiresMountsFor = "/mnt/data/actual";

  # lan only, the wireguard hub is the way in from outside
  networking.firewall.allowedTCPPorts = [ 5006 ];
}
