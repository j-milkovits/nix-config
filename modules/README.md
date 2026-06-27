## System Modules
> reusable NixOS modules
> should only be used if its necessary (system level, root access)

### Structure
```
modules/
├── system.nix    # base system settings
├── hyprland.nix  # hyprland system-level bits
├── nvidia.nix    # nvidia driver + OpenGL
└── README.md
```

### When to put something here vs `home/`
- here: kernel, drivers, services, system packages root needs (e.g. nvidia, hyprland's system bits)
- `home/`: tools and dotfiles for your user (e.g. nvim, zsh, kitty)
- rule of thumb: smaller system surface = more secure, more portable
