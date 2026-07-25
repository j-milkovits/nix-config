{ username
, sshAuthorizedKeys
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
}
