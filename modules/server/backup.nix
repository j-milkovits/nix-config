{ config
, lib
, ...
}:
let
  # the my book, its own usb bridge so one failing enclosure leaves the other filesystem up
  backupMount = "/mnt/backup";
  localRepo = "${backupMount}/restic";

  # ext4 has no snapshots, a torn sqlite page costs the whole history, seconds of downtime cost nothing
  # moves together with paths below
  stopUnits = [ "podman-actual" "podman-mealie" "podman-papra" ];

  # the same path containers.nix binds into the container, scanned paper is the one bulk that cannot be rescanned
  papraDocuments = "/mnt/data/media/papra/documents";

  systemctl = "${config.systemd.package}/bin/systemctl";
  restic = lib.getExe config.services.restic.backups.offsite.package;

  # one password for both repositories, the recovery key decrypts secrets/server.yaml, so no second copy anywhere
  passwordFile = config.sops.secrets."restic-password".path;

  # sized by time-to-notice: a broken database shows on the next open, a missing document a year later
  # a snapshot only costs the blobs no newer one shares, so the long tail is cheap
  pruneOpts = [
    "--keep-daily 7"
    "--keep-weekly 4"
    "--keep-monthly 12"
    "--keep-yearly 3"
  ];
in
{
  sops.secrets."restic-password" = { };

  # a b2 application key scoped to the one bucket, spoken to over the s3 api as restic recommends for b2
  sops.secrets."b2-key-id" = { };
  sops.secrets."b2-key" = { };
  # the module hands the repository credentials in as an EnvironmentFile, a template keeps them on the /run/secrets tmpfs
  sops.templates."restic-b2.env".content = ''
    AWS_ACCESS_KEY_ID=${config.sops.placeholder."b2-key-id"}
    AWS_SECRET_ACCESS_KEY=${config.sops.placeholder."b2-key"}
  '';

  services.restic.backups = {
    # the my book, copy 2, the only job that reads the live files
    local = {
      inherit passwordFile pruneOpts;
      repository = localRepo;

      # service state, plus the documents - the ingestion dir stays out, papra deletes from it once consumed
      paths = [
        "/var/lib/actual"
        "/var/lib/mealie"
        "/var/lib/papra"
        papraDocuments
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

      # reads a random tenth of the blobs back after the prune, rot shows in the journal, not at the restore
      checkOpts = [ "--read-data-subset=10%" ];
    };

    # backblaze b2, copy 3, the one that survives the house
    # fed from the local repository, not from the live files, so the services stop once a night and not twice
    offsite = {
      inherit passwordFile pruneOpts;
      repository = "s3:https://s3.eu-central-003.backblazeb2.com/jonasm-restic/restic";
      environmentFile = config.sops.templates."restic-b2.env".path;

      # no paths, so the module emits no backup command - the copy in preStart below is the transfer
      paths = [ ];
      initialize = true;

      # the local job triggers this one on success, a timer would race the local run on a late boot
      timerConfig = null;

      # structure only: egress is the one cost lever on b2, and the local leg already reads data back
      checkOpts = [ "--with-cache" ];
    };
  };

  systemd.services = {
    # both nofail: without the target restic inits a fresh repository into the bare mountpoint and reports success,
    # without the source it snapshots an empty documents dir that retention then turns into the only copy
    restic-backups-local = {
      unitConfig.RequiresMountsFor = [ backupMount papraDocuments ];
      # chains the offsite copy to a finished local run, a failed one leaves b2 as it was
      unitConfig.OnSuccess = [ "restic-backups-offsite.service" ];
    };

    restic-backups-offsite = {
      # the source repository lives on the nofail mount
      unitConfig.RequiresMountsFor = [ backupMount ];
      # after the module's own init, copies every snapshot b2 does not have yet - blobs shared between snapshots go once
      # target chunker params only matter for snapshots written straight into b2, and none ever are
      preStart = lib.mkAfter ''
        ${restic} copy --from-repo ${localRepo} --from-password-file ${passwordFile}
      '';
    };
  };
}
