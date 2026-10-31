{ username
, ...
}: {
  # the ssh host key doubles as the age identity (sops-nix default when sshd is enabled)
  sops.defaultSopsFile = ../../secrets/server.yaml;

  # read by the mealie-import skill (agents/) when claude runs here, owned by the user so the agent can read it
  # its own token, not the desktop's, so one host's token is revoked without the other
  sops.secrets."mealie-api-token".owner = username;
}
