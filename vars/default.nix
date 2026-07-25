{
  username = "jonasm";
  userFullName = "Jonas Milkovits";
  userEmail = "j.milkovits.t@posteo.net";

  # public keys that can log in to every host (referenced by modules/base/ssh.nix)
  # one key per client machine, generated locally there, the private key never leaves it
  sshAuthorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDtHD1iyc9XZ6VC8jQulrV/Lw9ilfq83SoaQiCscTc4r jonasm@desktop"
  ];
}
