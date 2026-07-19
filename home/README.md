## Home Manager Modules
> user-space configuration, imported per host via a profile
> should be used for as much as possible

### Structure
```
home/
├── headless/         # HM bootstrap + terminal environment (git, zsh, nvim, btop, ...)
├── gui/              # GUI-only modules (hyprland, kitty, rofi, waybar)
├── profiles/         # bundles per capability tier
│   ├── headless.nix  # headless
│   └── gui.nix       # headless + gui
└── README.md
```

### Capability tiers
- **headless**: full terminal environment (e.g. server, vps)
- **gui**: graphical apps and desktop environment

### How a host picks a profile
- `hosts/<name>/home.nix` imports `home/profiles/<tier>.nix`
- optional per-host module toggles go in the same file
