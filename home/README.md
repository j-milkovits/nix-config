## Home Manager Modules
> user-space configuration, imported per host via a profile
> should be used for as much as possible

### Structure
```
home/
├── core.nix      # username, homeDirectory, stateVersion
├── base/         # tools that go on every machine (git, nvim, zsh, ...)
├── gui/          # GUI-only modules (hyprland, kitty, rofi, waybar)
├── profiles/     # bundles per capability tier
│   ├── base.nix  # core + base
│   └── gui.nix   # base + gui
└── README.md
```

### How a host picks a profile
- `hosts/<name>/home.nix` imports `home/profiles/<tier>.nix`
- optional per-host module toggles go in the same file
