{ username
, ...
}: {
  # the ssh host key doubles as the age identity (sops-nix default when sshd is enabled)
  sops.defaultSopsFile = ../../secrets/desktop.yaml;

  # read by the mealie-import skill (agents/), owned by the user so the agent can read it, never in the store
  # its own token, not the server's, so one host's token is revoked without the other
  sops.secrets."mealie-api-token".owner = username;
}
