## Variables
> shared values passed through `specialArgs` / `extraSpecialArgs`

### Structure
```
vars/
├── default.nix  # identity (username, full name, email) + ssh public keys
└── README.md
```

### SSH keys
> `sshAuthorizedKeys` can log in to every host (referenced by `modules/base/ssh.nix`)
- one key per client machine
- generate locally: `ssh-keygen -t ed25519 -a 256 -C "jonasm@<host>"`
- the private key never leaves its machine; grant/revoke access = add/remove one line

### Forking
- edit `default.nix` to match your identity before first build
- vars are available to every module as top-level args (e.g. `{ username, userEmail, ... }: ...`)
