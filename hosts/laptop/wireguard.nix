{ config
, pkgs
, ...
}:
let
  serverPublicKey = "A4M3+CanqJjWKIR+ARuA0DqUor5OUnLfC3vAUB84UQk=";

  # the box name's A record reaches the forwarded server, its AAAA is the fritzbox
  # itself - and fritzos publishes no per-device name for a raw udp sharing, so the
  # only way to land on the server is to pin the address family
  endpointHost = "99fb9ja48145j52j.myfritz.net";
  endpointPort = 51820;
in
{
  # client of the hub in modules/server/wireguard.nix, this host is 10.100.0.3
  sops.secrets."wireguard-private-key".restartUnits = [ "wireguard-wg0.service" ];

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.3/24" ];
    privateKeyFile = config.sops.secrets."wireguard-private-key".path;
    # no listenPort: a roaming client takes an ephemeral one and opens no firewall hole

    peers = [
      {
        name = "server"; # only names the systemd unit
        publicKey = serverPublicKey;
        # split tunnel: the vpn subnet and the server itself, not the whole lan
        allowedIPs = [ "10.100.0.0/24" "192.168.178.85/32" ];
        # keep the nat mapping open so idle sessions stay two-way
        persistentKeepalive = 25;
      }
    ];
  };

  # pins the endpoint to v4, which peers.*.endpoint cannot express
  systemd.services.wg0-endpoint = {
    description = "point the wg0 peer at the ipv4 endpoint";
    after = [ "wireguard-wg0.service" "network-online.target" ];
    requires = [ "wireguard-wg0.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      set -- $(${pkgs.getent}/bin/getent ahostsv4 ${endpointHost})
      if [ -z "$1" ]; then
        echo "cannot resolve ${endpointHost} over ipv4" >&2
        exit 1
      fi
      ${pkgs.wireguard-tools}/bin/wg set wg0 peer ${serverPublicKey} \
        endpoint "$1:${toString endpointPort}"
    '';
  };

  # the endpoint address changes on the daily reconnect
  systemd.timers.wg0-endpoint = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1m";
      OnUnitInactiveSec = "5m"; # relative to the last run, so a failure retries too
    };
  };
}
