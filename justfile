# the commands this repo is driven with, `just` lists them

host := `hostname`

[private]
default:
    @just --list --unsorted

# build and switch this machine, or a named host
switch target=host:
    sudo nixos-rebuild switch --flake .#{{target}}

# build without switching, the cheap check before a switch or a deploy
build target=host:
    nixos-rebuild build --flake .#{{target}}

# build a host here and push it over ssh, `just switch-remote server`
switch-remote target:
    nixos-rebuild switch --flake .#{{target}} --target-host {{target}} --sudo --ask-sudo-password

# bump every flake input
update:
    nix flake update

# format every nix file
fmt:
    nixpkgs-fmt .

# edit a host's secrets, `just secrets server`
secrets target=host:
    sops secrets/{{target}}.yaml

# re-encrypt every secrets file after a .sops.yaml change
updatekeys:
    sops updatekeys secrets/*.yaml
