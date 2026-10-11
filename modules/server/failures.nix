{ config
, lib
, pkgs
, ...
}:
let
  # every unit here gets OnFailure, a crash reaches the phone instead of waiting to be noticed on the dashboard
  # podman units restart on their own, so they only land here once systemd gives up on them
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
in
{
  systemd.services = {
    # instantiated as notify-failure@<unit>.service by OnFailure, %i is the failed unit
    "notify-failure@" = {
      description = "post the failure of %i to ntfy";
      # ntfy-send comes from modules/server/ntfy.nix, by full path like the smartd hook
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "notify-failure" ''
          /run/current-system/sw/bin/ntfy-send "$1 failed on ${config.networking.hostName}" \
            "$(systemctl status --no-pager --lines 5 "$1" 2>&1 | tail -n 8)"
        '' + " %i";
      };
    };
  } // lib.genAttrs watchedUnits (_: {
    unitConfig.OnFailure = [ "notify-failure@%n.service" ];
  });
}
