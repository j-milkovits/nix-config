{ config
, lib
, ...
}:
let
  # the my book, its own usb bridge so one failing enclosure leaves the other filesystem up
  backupMount = "/mnt/backup";

  # ext4 has no snapshots, a torn sqlite page costs the whole history, seconds of downtime cost nothing
  # moves together with paths below
  stopUnits = [ "podman-actual" "podman-mealie" ];

  systemctl = "${config.systemd.package}/bin/systemctl";
in
{
  # the recovery key decrypts secrets/server.yaml, so no second copy anywhere
  sops.secrets."restic-password" = { };

  services.restic.backups.local = {
    repository = "${backupMount}/restic";
    passwordFile = config.sops.secrets."restic-password".path;

    # service state only, the document tool is undecided as of right now
    # its database and media dir join here once it is, scanned paper is the one bulk that cannot be rescanned
    paths = [
      "/var/lib/actual"
      "/var/lib/mealie"
    ];

    # first run creates the repository, every later one finds it
    initialize = true;

    # preStart, units are down before restic reads a page
    backupPrepareCommand = "${systemctl} stop ${lib.concatStringsSep " " stopUnits}";
    # postStop, runs even when the backup fails
    backupCleanupCommand = "${systemctl} start ${lib.concatStringsSep " " stopUnits}";

    timerConfig = {
      OnCalendar = "03:00";
      # a box that was off at 03:00 catches up on the next boot
      Persistent = true;
    };

    # sized by time-to-notice: a broken database shows on the next open, a missing document a year later
    # a snapshot only costs the blobs no newer one shares, so the long tail is cheap
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 12"
      "--keep-yearly 3"
    ];

    # reads a random tenth of the blobs back after the prune, rot shows in the journal, not at the restore
    checkOpts = [ "--read-data-subset=10%" ];
  };

  # nofail mount, without this restic inits a fresh repository into the bare mountpoint and reports success
  # /mnt/data joins the day a path under it enters paths, an absent source must fail the run, not back up an empty dir
  systemd.services.restic-backups-local.unitConfig.RequiresMountsFor = [ backupMount ];
}
