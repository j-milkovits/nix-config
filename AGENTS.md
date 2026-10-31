# AGENTS.md

> what is specific to this repo, the general rules are in [agents/global-rules.md](agents/global-rules.md)

## The repo
- one flake, four hosts: `desktop`, `laptop`, `server`, `wsl` - system layers under `modules/`, the user environment under `home/`, one folder per machine under `hosts/`
- the per-directory READMEs are the map, start there: [hosts](hosts/README.md), [modules](modules/README.md), [home](home/README.md), [secrets](secrets/README.md), [vars](vars/README.md), [agents](agents/README.md)

## Documentation
- when a change touches something a README covers (structure, workflows, trust model, inventory), update that README in the same change
- match the existing writing style:
    - `>` blockquote lines as one-line intros/tl;dr under headings
    - terse bullets, sentence fragments, no trailing periods
    - tables for structured comparisons, directory trees for structure, fenced blocks for commands
    - short *why* over long *what*, no filler prose

## Workflow
- commit scope = root-level folder or root file (`feat(modules): ...`, `feat(flake): ...`), one logical unit per commit
- `just` lists the everyday commands: `just switch` here, `just switch-remote server` builds the server and pushes it
- the server is never touched by an agent, commands are handed over - see the global rules

## Verifying
- `nixpkgs-fmt --check <file>` for every nix file touched, `stylua --check` for lua under `home/headless/nvim`
- an untracked file is invisible to the flake: evaluate through `path:.#nixosConfigurations.<host>.config...` until it is staged
- check option names against the nixos mcp server before using them, the module versions pinned here lag the docs
- `nix build 'path:.#nixosConfigurations.<host>.config.system.build.toplevel' --dry-run` is the whole-host check
