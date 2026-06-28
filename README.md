<h2 align="center">:snowflake: j-milkovits' Nix Config :snowflake:</h2>

<p align="center">
  <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png" width="400" />
</p>

## Modularization
> only relying on single `configuration.nix` & `home.nix` leads to major bloat 
> split configuration into submodules and import submodules in main modules
```
.
├── home/      # user-space (home-manager modules and profiles)
├── hosts/     # per-machine NixOS configurations
├── modules/   # system-space (NixOS modules)
├── vars/      # shared values (identity, etc.)
└── flake.nix  # entry point: inputs + nixosConfigurations
```
> see each directory's `README.md` for details

## Key Principles
- only install core components as NixOS modules that should be available to root aswell
- install as much as possible as a home manager module
    - makes NixOS more secure and stable
    - makes user space more portable to other non-NixOS systems

## Components
| Use Case                      | Application                       |
| ----------------------------- | --------------------------------- |
| **Window Manager**            | [Hyprland][Hyprland]              |
| **Terminal Emulator**         | [Kitty][Kitty]                    |
| **Shell**                     | [Zsh][Zsh]                        |
| **Plugin Manager**            | [Prezto][Prezto]                  |
| **Shell Prompt**              | [Powerlevel10k][Powerlevel10k]    |

## Screenshots

## Usage
> assumes a working NixOS install with flakes enabled

### Install
1. clone the repo to `~/nix-config`
    - `git clone git@github.com:j-milkovits/nix-config.git ~/nix-config`
2. drop in your own `hardware-configuration.nix` under `hosts/<host>/`
3. build and switch into the configuration
    - `noglob sudo nixos-rebuild switch --flake ~/nix-config#<host>`

### Update
1. bump all flake inputs to their latest revisions
    - `nix flake update --flake ~/nix-config`
2. rebuild and switch into the new generation
    - `noglob sudo nixos-rebuild switch --flake ~/nix-config#<host>`

## Why or why not?
> should you get started with Nix(OS)?
> conclusion: you should try it out and just make your own opinion
> benefits will grow immensely as soon as you manage multiple machines

### Advantages (over e.g. Arch + Ansible)
1. fully declarative, reproducible configuration
    - NixOS: describe entire system in a declarative way in text
    - produce identical environments everywhere
    - enhance reproducibility further combined with `flake.lock`
2. convenient system customization capability
    - declarative concept in a single file (without modularization)
    - safe and easy to perform modifications
3. effortless rollbacks + atomic upgrades
    - reboot into previous generation on fail
    - **no fear of breaking your system**
    - e.g. Ansible can leave your system in half-broken state
4. reproducible, isolated development/deployment
    - pin exact versions for dev tools, libraries, services,..
    - will guarantee the same result *everywhere*
5. no dependency conflicts
    - each software version has a unique hash
    - multiple version scan coexist

### Disadvantages
1. high (vertical) learning curve
    - achieving complete reproducibility leads to complexity
    - not a lot of linux knowledge carries over
2. disorganized documentation
    - flakes is still experimental feature 
    - therefore only classic approached covered in documentation
    - leads to sifting through a lot outdated information
    - large shout out to [NixOS & Flakes Book by ryan4yin](https://nixos-and-flakes.thiscute.world/introduction/)
3. increased disk space usage
    - historical environments for rollbacks require space
4. obscure error messages
    - often won't show where error is
    - probably one of the largest issues
    - often most effective way: binary search/gradual restoring

## References
> other .dotfiles that inspired me
- Modularization:
    - [ryan4yin - nix-config](https://github.com/ryan4yin/nix-config)
- Flakes:
- Neovim:
- GUI (Hyprland):

[Hyprland]: https://github.com/hyprwm/Hyprland
[Kitty]: https://github.com/kovidgoyal/kitty
[Zsh]: https://www.zsh.org/
[Prezto]: https://github.com/sorin-ionescu/prezto
[Powerlevel10k]: https://github.com/romkatv/powerlevel10k
[Waybar]: https://github.com/Alexays/Waybar
[rofi]: https://github.com/davatorium/rofi
[Dunst]: https://github.com/dunst-project/dunst
[Btop]: https://github.com/aristocratos/btop
[Neovim]: https://github.com/neovim/neovim
[Hyprshot]: https://github.com/Gustash/Hyprshot
[imv]: https://sr.ht/~exec64/imv/
[Nerd fonts]: https://github.com/ryanoasis/nerd-fonts
[catppuccin]: https://github.com/catppuccin/catppuccin
[NetworkManager]: https://wiki.gnome.org/Projects/NetworkManager
[wl-clipboard]: https://github.com/bugaevc/wl-clipboard
[Yazi]: https://github.com/sxyazi/yazi
