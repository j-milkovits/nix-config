## Home Manager Modules
> user-space configuration, imported per host via a profile
> should be used for as much as possible

### Structure
```
home/
├── core/         # HM bootstrap + baseline (git, zsh)
├── tui/          # terminal tools (btop, lazygit, nvim, ...)
├── gui/          # GUI-only modules (hyprland, kitty, rofi, waybar)
├── profiles/     # bundles per capability tier
│   ├── core.nix  # core
│   ├── tui.nix   # core + tui
│   └── gui.nix   # tui + gui
└── README.md
```

### Capability tiers
- **core**: minimum baseline (e.g. vps)
- **tui**: power-user terminal tooling (e.g. headless server)
- **gui**: graphical apps and desktop environment

### How a host picks a profile
- `hosts/<name>/home.nix` imports `home/profiles/<tier>.nix`
- optional per-host module toggles go in the same file
