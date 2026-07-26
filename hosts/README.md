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

### Network on `server`
> none of this is managed by nix, it lives in the fritzbox and at the registrar

| What | Value | Set where |
| --- | --- | --- |
| lan address | `192.168.178.85` | fritzbox, dhcp reservation |
| wireguard hub | `10.100.0.1` | `modules/server/wireguard.nix` |
| service names | `*.home.<domain>` → `192.168.178.85` | porkbun, one `A` record |

- the record points at the *lan* address, not the wireguard one, so services work at home with no tunnel
- roaming peers reach that same address over wireguard via `AllowedIPs = 10.100.0.0/24, 192.168.178.85/32`
- the `/32` scopes a peer to the server instead of the whole lan, and needs no forwarding or nat
- the wildcard record covers every future service, so a new service needs no dns change

**fritzbox**
- fixed ip: Heimnetz → Netzwerk → Netzwerkverbindungen → edit the host → *immer die gleiche IPv4-Adresse zuweisen*
- rebind exception: Heimnetz → Netzwerk → Netzwerkeinstellungen → *DNS-Rebind-Schutz*
- rebind protection discards public names resolving into private ranges, which is what breaks a homelab domain
- the field takes no wildcards and the parent domain does not cover subdomains
- so every service needs its full hostname listed, `actual.home.<domain>` - the one manual step per service

### Adding a new host
1. create `hosts/<name>/`
2. drop in `hardware-configuration.nix` from `nixos-generate-config`
3. write `default.nix` (start by copying an existing host)
4. write `home.nix` selecting a profile from `home/profiles/`
5. register the host in `flake.nix` under `nixosConfigurations`
6. after first boot: enroll its ssh host key for secrets (see `secrets/README.md`)
