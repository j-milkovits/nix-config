## System Modules
> reusable NixOS modules
> should only be used if its necessary (system level, root access)

### Structure
> split by layer first (base vs desktop), then by concern within the layer
```
modules/
├── base/              # universal: applies to every host
│   ├── user-group.nix # users, default shell (zsh)
│   ├── nix.nix        # nix.settings, gc, allowUnfree
│   ├── i18n.nix       # timezone, locale
│   ├── packages.nix   # root-level system packages
│   ├── storage.nix    # drive management (smartctl, parted, ddrescue, ...)
│   └── networking/
│       └── firewall.nix # on by default, hosts opt out
├── desktop/           # workstation-only
│   ├── fonts.nix
│   ├── peripherals.nix # audio (pipewire), printing (CUPS)
│   ├── nvidia.nix
│   ├── hyprland.nix
│   └── networking/
│       ├── firewall.nix # desktop opts out of the firewall
│       ├── networkmanager.nix
│       └── tailscale.nix
└── server/            # headless-server-only
    └── ssh.nix        # hardened openssh (key only, no root)
```

Each layer's `default.nix` imports its children, so hosts only need to pull in the layers they want:
```nix
imports = [
  ../../modules/base
  ../../modules/desktop
];
```

### When to put something here vs `home/`
- here: kernel, drivers, services, system packages root needs (e.g. nvidia, hyprland's system bits)
- `home/`: tools and dotfiles for your user (e.g. nvim, zsh, kitty)
- rule of thumb: smaller system surface = more secure, more portable

### When to put something in `base/` vs `desktop/`
- `base/`: would apply to a server, laptop, or wsl box too (users, locale, nix daemon, firewall)
- `desktop/`: only makes sense on a workstation (GPU driver, compositor, audio, font rendering)
- `server/`: only makes sense on a headless machine (sshd, later: containers, smartd, backups)
- future laptop/wsl hosts can opt into just `base/` and add their own peer-layer
