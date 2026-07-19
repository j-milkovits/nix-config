{ lib
, ...
}: {
  # on by default for every host, opt out per machine
  networking.firewall.enable = lib.mkDefault true;

  # open ports per host or per service module:
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
}
