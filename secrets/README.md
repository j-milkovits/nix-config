## Secrets
> encrypted with [sops](https://github.com/getsops/sops) + [age](https://github.com/FiloSottile/age), decrypted per host by [sops-nix](https://github.com/Mic92/sops-nix)
> safe to commit: values are ciphertext, only the yaml keys are readable

### How the pieces fit
- **age**: does the actual encryption, one keypair per person
- **sops**: encrypts the *values* of a yaml file to multiple recipients, `git diff` shows which secret changed but not its content
- **ssh-to-age**: derives a host's age key from its ssh host key (`/etc/ssh/ssh_host_ed25519_key`), so machines need no extra key material
- **sops-nix** (flake input): decrypts declared secrets at activation with the host's ssh key and places them under `/run/secrets/<name>` (tmpfs, never the nix store)

### Trust model
- your personal age key decrypts everything
- each host only decrypts files that `.sops.yaml` grants it
- the repo itself can be public

### Workflows
```bash
# edit (or create) a secret file — opens $EDITOR with plaintext, re-encrypts on save
sops secrets/<file>.yaml

# reference it in a module
sops.secrets."wireguard/server-private-key" = { };
# → available at config.sops.secrets."wireguard/server-private-key".path

# enroll a new host: get its age pubkey, add to .sops.yaml, re-wrap the files
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
sops updatekeys secrets/<file>.yaml
```

### Disaster answers
- lost personal key → restore `keys.txt` from the password manager backup
- reinstalled host (new ssh host key) → re-enroll like a new host, `sops updatekeys`
- leaked personal key → generate new key, `updatekeys` everything, **rotate the secret values themselves** (updatekeys only re-wraps, history still decrypts with the old key)
