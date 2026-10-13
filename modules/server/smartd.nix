{ pkgs
, ...
}:
let
  # by identity, sd* reorders between boots - the m.2 answers through nvme-cli instead
  disks = [
    "/dev/disk/by-id/ata-ST4000VN006-3CW104_WW6A996V" # ironwolf, /mnt/data
    "/dev/disk/by-id/ata-WDC_WD80EDAZ-11TA3A0_VDKT9ESK" # my book, /mnt/backup
  ];

  # smartd hands the alert over in its environment and runs the hook with an empty path
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

    # short test saturdays 05:00, long test on the first of the month 05:00, a missed slot runs at the next check
    # the my book's bridge answers no power query, so -n cannot skip it and every check is a wake-up
    defaults.monitored = "-a -S on -n standby,q -s (S/../../6/05|L/../01/./05) -m <nomailer> -M exec ${hook}";

    # -d sat, both bridges pass the ata commands through
    devices = map (device: { inherit device; options = "-d sat"; }) disks;

    # once a day, the default of thirty minutes kept the my book spinning at 63 degrees
    extraOptions = [ "--interval=86400" ];
  };
}
