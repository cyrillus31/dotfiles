# DOTFILES

## Requirements

---

- [stow](https://www.gnu.org/software/stow/manual/stow.html)

## Usage:

### Makefile targets:

- fedora
- macbook
- yandex_macbook
- common
- backup (to backup _some_ shell related files)
- all
- help

## Todo:

- [x] Implement various profiles to exclude certain packages from stowing.
- [ ] CLI app
- [ ] Distribute with Stow included
- [ ] GUI

## Dependencies

#### Macbook

```
brew install zsh-autosuggestions stow

```

## Compatible installation and checks

Existing profile targets and `make update` keep their additive behavior. Stow
still targets the checkout's parent directory by default. For a checkout located
elsewhere, pass `STOW_TARGET="$HOME"` explicitly.

```sh
make dry-run PROFILE=macbook STOW_TARGET="$HOME"
make macbook STOW_TARGET="$HOME"
make check
```

`make reconcile PROFILE=macbook` is an **opt-in** profile switch: it previews the
combined operation, removes links for packages unique to the saved profile, and
installs the new profile. It does not delete package contents. With no saved
profile, no previous profile is assumed. Normal profile targets never remove
old profile packages. Avoid concurrent profile installations (`make -j`).

`make backup` still moves existing configs out of the way. Backups now live in
unique `~/.dotfiles-backup.*` directories, include directories and dangling
symlinks, and report failures. `make backup-copy` copies instead of moving.

Checks require Python 3.11+, Bash, Zsh, and GNU Stow. Optional interactive tools
include Starship, fzf, fastfetch, zsh-autosuggestions, tmux, and rustyvibes. Install
the tools used by your chosen profile before expecting their integrations to work.

## Codex

The `ai_agents` package now installs Codex alongside Claude and OpenCode:

- `~/.agents/skills/`: 24 skills covering the locally available Claude workflows.
- `~/.codex/AGENTS.md`: the existing teaching, writing, ticket, and knowledge-map
  instructions adapted for Codex.
- `~/.codex/hooks/herdr-session.py`: optional Herdr session identification.

```sh
make codex-setup STOW_TARGET="$HOME"
make codex-mcp STOW_TARGET="$HOME"  # optional: import local Claude HTTP MCP declarations
make codex-doctor
```

Install the Codex CLI separately and use `codex login` for authentication.
`codex-setup` first stows the agent files, then adds missing configuration values:
reasoning effort, an instruction-reading budget large enough for the existing
instructions, OpenAI documentation MCP, optional research/review profiles, and
the Herdr SessionStart hook. Review and trust that hook through Codex `/hooks`
before it can run; installing it does not grant hook trust. Existing values, model selection, comments, project
trust, permissions, credentials, and server settings take precedence. Configuration
updates get unique backups. Plain `make ai_agents` only installs files and does
not edit `config.toml`. Stow reports conflicts instead of replacing existing files.

`codex-mcp` reads user-level HTTP servers from local `~/.claude.json`; unsupported
transports and URLs containing credentials/query parameters are skipped. URLs are
written only to the local Codex config. Header values are **never copied**: the
command prints environment variable names to set locally with the full header
value (including `Bearer ` where applicable). Existing Codex server values win.
Use `codex mcp login <server>` for servers requiring OAuth. Project-scoped Claude
MCP declarations are not imported automatically.

Invoke skills as `$gitlab`, `$walkthrough`, `$ticket-log`, etc. The imported
skill-creation capability is named `$skill-creator-synced` to avoid colliding with
the built-in `$skill-creator`. Browser, desktop, Google Workspace, memory, and
briefing skills require their corresponding connected tools; instructions do not
install those integrations. Service-restricted synced skills have original
Codex workflows rather than redistributed service assets. Ponytail skills retain
their MIT notices; Claude-only plugin UI and Band hooks are not installed.

Claude skills remain in `.claude/skills`. Codex adaptations live in
`.agents/skills`; keep both versions aligned when changing a custom workflow.
The ticket effort implementation is shared through a relative symlink. Add
`--codex-sessions "${CODEX_HOME:-$HOME/.codex}/sessions"` to include Codex human
prompt events without counting duplicate message representations or tool output.
Codex logs supply prompt activity and first mentions; they do not prove code edits
or planning transitions. Knowledge-map and walkthrough state are separate under
`~/.codex`; existing Claude state is not moved.

The supplied Make targets use the standard `~/.codex` layout. For a custom
`CODEX_HOME`, install the instruction/hook files there and run
`python3 scripts/setup-codex.py --codex-home "$CODEX_HOME"`; user skills remain in
`~/.agents/skills`. Voice, spinner text, cleanup windows, and Claude auto-mode
settings are host-specific and are not translated into unrelated Codex settings.

References: [Codex skills](https://learn.chatgpt.com/docs/build-skills),
[configuration](https://learn.chatgpt.com/docs/config-file/config-reference),
[MCP](https://learn.chatgpt.com/docs/extend/mcp?surface=cli), and
[hooks](https://learn.chatgpt.com/docs/hooks).
