{ config
, lib
, pkgs
, ...
}:
let
  # every unit here gets OnFailure, a crash reaches the phone instead of waiting to be noticed on the dashboard
  watchedUnits = [
    "restic-backups-local"
    "restic-backups-offsite"
    "podman-actual"
    "podman-mealie"
    "podman-papra"
    "podman-twitch-drops-miner"
    "immich-server"
    "immich-machine-learning"
    "postgresql"
    "caddy"
    "smartd"
  ];

  # a unit that is back within this is a blip, not an incident
  # a crash the restart policy fixes stays silent, a crash loop ends with systemd giving up and the unit still down
  gracePeriod = "5min";
in
{
  systemd.services = {
    # instantiated as notify-failure@<unit>.service by OnFailure, %i is the failed unit
    "notify-failure@" = {
      description = "post the failure of %i to ntfy, unless it is back within ${gracePeriod}";
      # ntfy-send comes from modules/server/ntfy.nix, by full path like the smartd hook
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "notify-failure" ''
          sleep ${gracePeriod}
          # the nightly backup stops services for as long as its run takes (modules/server/backup.nix), judge afterwards
          while [ "$(systemctl is-active restic-backups-local)" = activating ]; do sleep 30; done
          systemctl is-active --quiet "$1" && exit 0
          /run/current-system/sw/bin/ntfy-send "$1 failed on ${config.networking.hostName}" \
            "$(systemctl status --no-pager --lines 5 "$1" 2>&1 | tail -n 8)"
        '' + " %i";
      };
    };
  } // lib.genAttrs watchedUnits (_: {
    unitConfig.OnFailure = [ "notify-failure@%n.service" ];
  });
}
