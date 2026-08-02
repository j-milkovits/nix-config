## Secrets
> encrypted with [sops](https://github.com/getsops/sops) + [age](https://github.com/FiloSottile/age), decrypted per host by [sops-nix](https://github.com/Mic92/sops-nix)
> safe to commit: values are ciphertext, only the yaml keys are readable

### How the pieces fit
- **age**: does the actual encryption, ssh ed25519 keys double as age keys (no separate age key material)
- **sops**: encrypts the *values* of a yaml file to multiple recipients, `git diff` shows which secret changed but not its content
- **ssh-to-age**: converts an ssh public key into the `age1...` recipient string sops-nix expects for host keys
- **sops-nix** (flake input): decrypts declared secrets at activation with the host's ssh host key and places them under `/run/secrets/<name>` (tmpfs, never the nix store)

### Trust model
> everything is an ssh ed25519 key, each private key is generated on the machine it lives on and never leaves it
- a secret is encrypted to *all* recipients its creation rule lists, any single matching private key decrypts it
- least privilege: one secrets file per host, a host's key is only a recipient of its own file
- new recipients only apply on re-encryption → `sops updatekeys secrets/*.yaml` after every `.sops.yaml` change
- the repo itself can be public
- **editing happens on the desktop only**, no roaming machine gets a key that opens more than its own file

### How a secrets file works (envelope encryption)
> the yaml key names stay plaintext (diffable, referencable), only the values are ciphertext
- the values are encrypted with a random one-off AES **data key**, not with age directly
- the `sops:` block at the bottom holds that data key, wrapped once per recipient (`age:` list)
- decrypting = unwrap your copy of the data key, then decrypt the values with it
- `updatekeys` only re-wraps the data key for the current recipient list, values are untouched
- `.sops.yaml` is pure policy for the cli: consulted at encrypt/rekey time, never read by hosts

### Who decrypts with what
| Identity | Key | Why |
| --- | --- | --- |
| you (editing with the sops cli) | `~/.ssh/id_ed25519`, found automatically | same key as for ssh login, one recipient per machine you edit secrets on |
| every host (sshd runs everywhere) | its ssh host key (`/etc/ssh/ssh_host_ed25519_key`) | exists from first boot, nothing to generate or distribute |
| recovery | offline ssh key, lives only in the password manager | last resort if every machine is lost, never deployed |

> a machine that only *receives* secrets (server) needs no personal key as recipient -
> your personal keys are purely for the cli editing workflow

> two recipient notations in `.sops.yaml`: hosts use the ssh-to-age `age1...` form (what sops-nix
> matches at activation), the personal key uses the native `ssh-ed25519 ...` form (what the sops
> cli auto-detects from `~/.ssh/id_ed25519`) - they are not interchangeable

### Workflows
```bash
# edit (or create) a secret file - opens $EDITOR with plaintext, re-encrypts on save
sops secrets/<file>.yaml

# reference it in a module
sops.secrets."wireguard-private-key" = { };
# → available at config.sops.secrets."wireguard-private-key".path

# enroll a new host: get its age pubkey, add to .sops.yaml, re-wrap the files
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
sops updatekeys secrets/*.yaml
```

### Disaster answers
- lost personal key → generate a new one, enroll it via a host key or the recovery key, `updatekeys`
- reinstalled host (new ssh host key) → re-enroll like a new host, `sops updatekeys`
- every machine lost → restore the recovery key from the password manager, decrypt manually:
  `SOPS_AGE_KEY_CMD='ssh-to-age -private-key -i <recovery-key>' sops -d secrets/<file>.yaml`
    - the recovery key is enrolled in the `age1...` form, so sops needs an age identity, not the ssh key itself
    - a key enrolled in the native `ssh-ed25519 ...` form takes the other route instead:
      `SOPS_AGE_SSH_PRIVATE_KEY_CMD='cat <key>' sops -d secrets/<file>.yaml`
- leaked key → remove it from `.sops.yaml`, `updatekeys`, **rotate the secret values themselves** (updatekeys only re-wraps, git history still decrypts with the old key)
