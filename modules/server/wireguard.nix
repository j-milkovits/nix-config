{ config
, ...
}: {
  # hub of the vpn: clients (phone, laptop) connect here from outside, each peer gets a /32 in 10.100.0.0/24
  sops.secrets."wireguard-private-key" = { };

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.1/24" ];
    listenPort = 51820;
    privateKeyFile = config.sops.secrets."wireguard-private-key".path;

    peers = [
      {
        # desktop
        publicKey = "TH/10kwyV9hny0HCsB2pISIdr9dPZFNqCxG7l9UCj1U=";
        allowedIPs = [ "10.100.0.2/32" ];
      }
    ];
  };

  networking.firewall.allowedUDPPorts = [ 51820 ];
}
