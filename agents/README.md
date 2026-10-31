## Agents
> the tool-agnostic source of truth for how coding agents work here, consumed through thin per-tool pointers

### Structure
```
agents/
├── global-rules.md   # how an agent works for me, on any repo - becomes ~/.claude/CLAUDE.md
├── skills/           # one folder per skill with a SKILL.md (Agent Skills format), linked into ~/.claude/skills/ - none yet
└── README.md
```

| Layer | Lives in | Loaded how |
| --- | --- | --- |
| global rules | `agents/global-rules.md` | `programs.claude-code.context` in `home/headless/claude-code.nix` |
| global skills | `agents/skills/<name>/` | `programs.claude-code.skills`, every folder, no nix per skill |
| repo rules | `AGENTS.md` at the root | `CLAUDE.md` is a one-line import of it, other tools read it directly |
| repo skills | `.agents/skills/<name>/` | discovered by agents in the checkout, none yet |

- one canonical home per fact, the layers link to each other instead of repeating
- the files carry no tool name, the pointers do - a second agent gets its own pointer, not a copy
- adding a skill is adding a folder, then `just switch` so its link exists
- secrets a skill needs are never in the repo or the store: sops places them under `/run/secrets/<name>` owned by the user, the skill reads the path - `mealie-api-token` on the desktop and the server, a separate token each
