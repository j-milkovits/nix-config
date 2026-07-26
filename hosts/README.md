## Hosts
> machine-specific configuration
> each host folder is one NixOS configuration entry

### Inventory
| Host      | Platform | Hardware           | Purpose    | Status     |
| --------- | -------- | ------------------ | ---------- | ---------- |
| `desktop` | NixOS    | AMD + NVIDIA       | Daily Use  | ✅ Active  |
| `server`  | NixOS    | Dell OptiPlex 3070 | Homelab    | ✅ Active  |

### Storage on `server`

```
/mnt/data/            # ironwolf 4tb, ext4, addressed by disk id
├── services/<name>/  # container state (e.g. sqlite, config), one dir per container
└── media/            # bulk originals (e.g. immich library, paperless documents)
```

- the split is the backup boundary: state is backed up with the service stopped, media streams live
- mounted `nofail` - the drive sits in a usb enclosure, a bridge that fails to enumerate must not hold up the boot
- so every container carries `RequiresMountsFor` on its state dir, see `modules/server/containers.nix`

### Adding a new host
1. create `hosts/<name>/`
2. drop in `hardware-configuration.nix` from `nixos-generate-config`
3. write `default.nix` (start by copying an existing host)
4. write `home.nix` selecting a profile from `home/profiles/`
5. register the host in `flake.nix` under `nixosConfigurations`
6. after first boot: enroll its ssh host key for secrets (see `secrets/README.md`)
