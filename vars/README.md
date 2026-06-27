## Variables
> shared values passed through `specialArgs` / `extraSpecialArgs`

### Structure
```
vars/
├── default.nix  # identity (username, full name, email)
└── README.md
```

### Forking
- edit `default.nix` to match your identity before first build
- vars are available to every module as top-level args (e.g. `{ username, userEmail, ... }: ...`)
