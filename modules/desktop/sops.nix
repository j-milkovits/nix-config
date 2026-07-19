{ username
, ...
}: {
  # the desktop runs no sshd, so there is no host key to derive an age key
  # from — decrypt with the personal age key instead
  sops.age.keyFile = "/home/${username}/.config/sops/age/keys.txt";

  sops.defaultSopsFile = ../../secrets/desktop.yaml;

  # proof of the pipeline, lands in /run/secrets/test after rebuild
  sops.secrets.test = { };
}
