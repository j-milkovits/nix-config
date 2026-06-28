{ pkgs
, ...
}: {
  # make the tailscale command usable to users
  environment.systemPackages = [ pkgs.tailscale ];

  # enable the tailscale service
  # after rebuild, authenticate once with `sudo tailscale up`
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "client";
  };
}
