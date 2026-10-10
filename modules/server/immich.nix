{ config
, domain
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

    # the deviations from immich's defaults, the admin ui shows the whole page read-only from here on
    settings = {
      # share links and the app build absolute urls from this
      server.externalDomain = "https://immich.home.${domain}";
      # originals land as <storage label>/<year>/<date>/<original name>, a tree that reads without immich
      storageTemplate.enabled = true;
      # restic takes the stopped postgres dir nightly, a second dump inside the library would be a second mechanism
      backup.database.enabled = false;
      # nix picks the version
      newVersionCheck.enabled = false;
      # restic stops immich at 03:00 (modules/server/backup.nix), nothing of immich's may be running then
      nightlyTasks.startTime = "04:00";
      # sunday 06:00, after the nightly tasks - the checksum pass is what notices bit rot on ext4
      integrityChecks = {
        checksumFiles = { enabled = true; cronExpression = "0 06 * * 0"; };
        missingFiles = { enabled = true; cronExpression = "0 06 * * 0"; };
        untrackedFiles = { enabled = true; cronExpression = "0 06 * * 0"; };
      };
    };
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
