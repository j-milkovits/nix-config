{ username
, ...
}: {
  # the client side, the host keys it trusts come from modules/base/ssh.nix
  programs.ssh = {
    enable = true;
    # the module's legacy defaults are on their way out, the "*" block below is the explicit set
    enableDefaultConfig = false;

    settings = {
      "*" = {
        User = username;
        IdentityFile = "~/.ssh/id_ed25519";
        # a wireguard peer behind nat loses idle connections, the keepalive holds them
        ServerAliveInterval = 30;
        ServerAliveCountMax = 3;
      };

      # the lan address works from home and through the tunnel, the laptop routes it (hosts/README.md)
      # the other hosts have no fixed address
      server.HostName = "192.168.178.85";
    };
  };
}
