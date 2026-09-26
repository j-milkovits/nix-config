{ config
, ...
}: {
  # hub of the vpn: clients (phone, laptop) connect here from outside, each peer gets a /32 in 10.100.0.0/24
  sops.secrets."wireguard-private-key" = { };

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.1/24" ];
    listenPort = 51820;
    privateKeyFile = config.sops.secrets."wireguard-private-key".path;

    # peers are added at enrollment, keys are generated on the client itself
    # allowedIPs here is a routing table, not a permission: a /32 keeps the peer to its own address
    peers = [
      {
        # phone
        publicKey = "Q+bCM+iWFT8TM8a4x20w9w72AdsdxDj08optO7u9jGc=";
        allowedIPs = [ "10.100.0.2/32" ];
      }
      {
        # laptop, client config in hosts/laptop/wireguard.nix
        publicKey = "pIXk/r5KMNBeF6dkIgnMieK/EyZcluwU8ogcHvsMVks=";
        allowedIPs = [ "10.100.0.3/32" ];
      }
    ];
  };

  networking.firewall.allowedUDPPorts = [ 51820 ];
}
