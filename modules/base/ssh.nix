{ lib
, username
, sshAuthorizedKeys
, sshHostKeys
, ...
}: {
  # runs on every host: the host key it generates doubles as the sops decryption identity
  services.openssh = {
    # opens port 22 in the firewall by default (openFirewall = true)
    enable = true;

    settings = {
      # key only, no passwords to brute force
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  users.users.${username}.openssh.authorizedKeys.keys = sshAuthorizedKeys;

  # every host trusts every other host's key from the first connection, a changed key is an error and not a prompt
  # the client side (aliases, keepalive) lives in home/headless/ssh.nix
  programs.ssh.knownHosts = lib.mapAttrs
    (_: host: {
      hostNames = host.names;
      publicKey = host.key;
    })
    sshHostKeys;
}
