{
  username = "jonasm";
  userFullName = "Jonas Milkovits";
  userEmail = "j.milkovits.t@posteo.net";

  # domain registered at porkbun, homelab services are subdomains of home.<domain>
  domain = "jonas-milkovits.com";

  # public keys that can log in to every host (referenced by modules/base/ssh.nix)
  # one key per client machine, generated locally there, the private key never leaves it
  sshAuthorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDtHD1iyc9XZ6VC8jQulrV/Lw9ilfq83SoaQiCscTc4r jonasm@desktop"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBk/MP20rvoYjbwnvYBZrn/8ADony+KkLebQznZK4h9J jonasm@laptop"
  ];

  # the public half of every host's ssh host key, pinned as known hosts on every other host (modules/base/ssh.nix)
  # the same key is the sops identity, so a reinstall changes it here and in .sops.yaml in one commit
  # read off the host with `cat /etc/ssh/ssh_host_ed25519_key.pub`
  sshHostKeys = {
    server = {
      names = [ "server" "192.168.178.85" "10.100.0.1" ];
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKUJ4EGLjtC3+KOmzI236+MQohSczaLrdMfrU6yrfnqm";
    };
    desktop = {
      names = [ "desktop" ];
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMgFrknaNBZMc81LJBkf8ZuZ3jARR3zAZhdi8tSSNcn+";
    };
    laptop = {
      names = [ "laptop" "10.100.0.3" ];
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJKe40si31VVh7C6BCFPWeB1wRRioeYdesAIo0yznsKX";
    };
  };
}
