## Hosts
> machine-specific configuration
> each host folder is one NixOS configuration entry

### Inventory
| Host      | Platform | Hardware           | Purpose    | Status         |
| --------- | -------- | ------------------ | ---------- | -------------- |
| `desktop` | NixOS    | AMD + NVIDIA       | Daily Use  | ✅ Active      |
| `server`  | NixOS    | Dell OptiPlex 3070 | Homelab    | ✅ Active      |
| `laptop`  | NixOS    | Intel, integrated  | Mobile     | ✅ Active      |

### What a host folder owns
> the layers under `modules/` are shared, so anything true of one machine only lives here

| Concern | File | Why it cannot be shared |
| --- | --- | --- |
| GPU driver | `nvidia.nix` | a laptop is integrated intel/amd, `modules/desktop/graphics.nix` carries only `hardware.graphics` |
| secrets file | `sops.nix` | hardcodes `secrets/<host>.yaml` |
| firewall stance | `firewall.nix` | "trusted home network" is a claim about this lan, a roaming machine keeps the `base/` default |
| disk layout | `disko.nix` | one disk id, one machine |
| vpn client | `wireguard.nix` | one address and one keypair per peer, the hub itself lives in `modules/server/` |

- `base/` sets `networking.firewall.enable = lib.mkDefault true`, so a host that says nothing is firewalled
- opting out is a per-machine decision and has to be written down as one

### Storage on `server`

```
/var/lib/<name>/      # host fs, service state: sqlite databases and config
/mnt/data/            # ironwolf 4tb, ext4, addressed by disk id
└── media/            # bulk originals (e.g. immich library, paperless documents)
```

- the split is a durability boundary (usb bridges can be unreliable)
- so databases stay on the m.2 and only write-once bulk goes on the external drive
- it is a backup boundary too: state is dumped with the service stopped, media streams live
- `/mnt/data` is mounted `nofail` - a bridge that fails to enumerate must not hold up the boot
- so anything binding a path under it needs `RequiresMountsFor`, while `/var/lib` needs none, see `modules/server/containers.nix`

### Network on `server`
> none of this is managed by nix, it lives in the fritzbox and at the registrar

| What | Value | Set where |
| --- | --- | --- |
| lan address | `192.168.178.85` | fritzbox, dhcp reservation |
| wireguard hub | `10.100.0.1` | `modules/server/wireguard.nix` |
| service names | `*.home.<domain>` → `192.168.178.85` | porkbun, one `A` record |
| vpn endpoint | `<boxid>.myfritz.net:51820` | fritzbox, myfritz! ddns |

| Peer | Address | Keys generated |
| --- | --- | --- |
| `server` (hub) | `10.100.0.1` | on the server, private half in `secrets/server.yaml` |
| phone | `10.100.0.2` | in the app, only the public half ever entered the repo |
| `laptop` | `10.100.0.3` | on the laptop, private half in `secrets/laptop.yaml` |

- the record points at the *lan* address, not the wireguard one, so services work at home with no tunnel
- roaming peers reach that same address over wireguard via `AllowedIPs = 10.100.0.0/24, 192.168.178.85/32`
- the endpoint lives in `hosts/laptop/wireguard.nix`: wireguard never answers an unauthenticated packet, so an open 51820 discloses little, and the box has no remote admin
- it is pinned to ipv4 and re-resolved on a timer, see the endpoint trap below
- the `/32` scopes a peer to the server instead of the whole lan, and needs no forwarding or nat
- the wildcard record covers every future service, so a new service needs no dns change

**fritzbox**
- fixed ip: Heimnetz → Netzwerk → Netzwerkverbindungen → edit the host → *immer die gleiche IPv4-Adresse zuweisen*
- rebind exception: Heimnetz → Netzwerk → Netzwerkeinstellungen → *DNS-Rebind-Schutz*
- rebind protection discards public names resolving into private ranges, which is what breaks a homelab domain
- the field takes no wildcards and the parent domain does not cover subdomains
- so every service needs its full hostname listed, `actual.home.<domain>` - the one manual step per service
- wireguard forward: Internet → Freigaben → Portfreigaben → the host → udp 51820, ticked for ipv4 *and* ipv6
- v4 is a real forward through nat, v6 is only a firewall release, the host is addressed directly

**the endpoint trap**
> the box name's `A` reaches the forwarded server, its `AAAA` is the fritzbox

- a resolver following rfc 6724 prefers the `AAAA`, so a v6-capable client hands its handshakes to the router
- no public name resolves to the server over v6: fritzos mints per-device myfritz names only for its known application sharings, not for a raw udp port
- so clients pin the family themselves, see the `wg0-endpoint` unit in `hosts/laptop/wireguard.nix`

### Adding a new host
1. create `hosts/<name>/`
2. drop in `hardware-configuration.nix` from `nixos-generate-config`
3. write `default.nix` (start by copying an existing host)
4. write `home.nix` selecting a profile from `home/profiles/`
5. register the host in `flake.nix` under `nixosConfigurations`
6. after first boot: enroll its ssh host key for secrets (see `secrets/README.md`)
