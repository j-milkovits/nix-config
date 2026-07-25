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
    peers = [ ];
  };

  networking.firewall.allowedUDPPorts = [ 51820 ];
}
