## Hosts
> machine-specific configuration
> each host folder is one NixOS configuration entry

### Inventory
| Host      | Platform | Hardware           | Purpose    | Status     |
| --------- | -------- | ------------------ | ---------- | ---------- |
| `desktop` | NixOS    | AMD + NVIDIA       | Daily Use  | ✅ Active  |
| `server`  | NixOS    | Dell OptiPlex 3070 | Homelab    | 🚧 Planned |

### Adding a new host
1. create `hosts/<name>/`
2. drop in `hardware-configuration.nix` from `nixos-generate-config`
3. write `default.nix` (start by copying an existing host)
4. write `home.nix` selecting a profile from `home/profiles/`
5. register the host in `flake.nix` under `nixosConfigurations`
