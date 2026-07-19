{ username
, ...
}: {
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

  users.users.${username}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDzekmhsAB/sz6qzS51rYbgSiDVrV9BfBNpCtDojoZZ7 jonasm@desktop"
  ];
}
