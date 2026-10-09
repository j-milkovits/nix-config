{ config
, pkgs
, pkgs-unstable
, ...
}:
let
  # the library on the ironwolf like every other bulk, the database stays on the m.2 under /var/lib/postgresql
  mediaLocation = "/mnt/data/media/immich";
  inherit (config.services.immich) user group;
in
{
  # the nixos module, it brings postgres and redis wired up over unix sockets
  services.immich = {
    enable = true;
    inherit mediaLocation;
    # 127.0.0.1, not localhost: caddy and the dashboard monitor dial v4 (modules/server/proxy.nix, dashboard.nix)
    host = "127.0.0.1";
    # 26.05 carries immich 2.x, end of life with open cves and refused by nixpkgs - 3.x lives in unstable until 26.11
    package = pkgs-unstable.immich;

    # faces and search on the cpu, a photo is indexed once on upload
    machine-learning.enable = true;
  };

  systemd.services.immich-server = {
    # /mnt/data is nofail, without this immich starts with the bridge absent and uploads into the bare mountpoint
    unitConfig.RequiresMountsFor = [ mediaLocation ];
    # the module only fixes ownership of a dir that exists, it creates none outside /var/lib - the + runs this as root
    serviceConfig.ExecStartPre = [
      "+${pkgs.coreutils}/bin/install -d -m 0700 -o ${user} -g ${group} ${mediaLocation}"
    ];
  };
}
