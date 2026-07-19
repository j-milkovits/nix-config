{
  # the ssh host key doubles as the age identity (sops-nix default when sshd is enabled)
  sops.defaultSopsFile = ../../secrets/server.yaml;
}
