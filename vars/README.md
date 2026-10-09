## Variables
> shared values passed through `specialArgs` / `extraSpecialArgs`

### Structure
```
vars/
├── default.nix  # identity (username, full name, email), domain, ssh public keys, host keys
└── README.md
```

### SSH keys
> `sshAuthorizedKeys` can log in to every host (referenced by `modules/base/ssh.nix`)
- one key per client machine
- generate locally: `ssh-keygen -t ed25519 -a 256 -C "jonasm@<host>"`
- the private key never leaves its machine; grant/revoke access = add/remove one line

### Host keys
> `sshHostKeys` pins every host's ssh host key as a known host on every other host (referenced by `modules/base/ssh.nix`)
- the first connection is trusted without a prompt, a changed key is an error and not a question to click through
- read off the host: `cat /etc/ssh/ssh_host_ed25519_key.pub`, drop the trailing comment
- `names` lists every name and address the host is reached by, the wireguard address included
- the same key is the sops identity, a reinstall regenerates it: update it here and in `.sops.yaml` in one commit

### Forking
- edit `default.nix` to match your identity before first build
- vars are available to every module as top-level args (e.g. `{ username, userEmail, ... }: ...`)
