{ pkgs
, ...
}:
let
  # the two usb disks by identity, sd* reorders between boots - the m.2 answers through nvme-cli instead
  disks = [
    "/dev/disk/by-id/ata-ST4000VN006-3CW104_WW6A996V" # ironwolf, /mnt/data
    "/dev/disk/by-id/ata-WDC_WD80EDAZ-11TA3A0_VDKT9ESK" # my book, /mnt/backup
  ];

  # smartd hands the alert over in its environment and runs the hook with a path of its own, hence the full path
  hook = pkgs.writeShellScript "smartd-ntfy" ''
    /run/current-system/sw/bin/ntfy-send "$SMARTD_SUBJECT" "$SMARTD_MESSAGE"
  '';
in
{
  services.smartd = {
    enable = true;
    # only the two listed, autodetect would also pick up whatever is plugged in for a copy
    autodetect = false;
    # the module's own hook only serves wall, mail and x11, the exec below replaces it
    notifications = {
      wall.enable = false;
      mail.enable = false;
    };

    # -a every check, -o -S the drive's own offline tests and attribute autosave
    # -n standby,q skips a parked disk instead of waking it, the my book parks between the nightly runs
    # -s short test saturdays 05:00, long test on the first of the month 05:00 - both after the 03:00 backup,
    #    a first that falls on a sunday shares the ironwolf with the immich integrity check for a few hours, reads both
    # -m <nomailer> -M exec: no mail, the hook posts to ntfy (modules/server/ntfy.nix)
    defaults.monitored = "-a -o on -S on -n standby,q -s (S/../../6/05|L/../01/./05) -m <nomailer> -M exec ${hook}";

    # -d sat, both bridges pass the ata commands through
    devices = map (device: { inherit device; options = "-d sat"; }) disks;
  };
}
