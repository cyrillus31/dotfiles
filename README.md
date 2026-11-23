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

## Herdr session restore for Codex

Run `herdr integration install codex` once per machine. In a Codex pane, open
`/hooks` and trust the Herdr `SessionStart` hook if it is awaiting review.
Send a prompt to register the conversation ID with Herdr.

The `herdr` package enables session restore. The `shell_zsh` package runs Codex
with `--no-daemon` inside Herdr so the hook receives the current pane's ID.
After a Herdr restart, a registered pane runs `codex resume <id>` automatically.
If a pane comes back as a shell, resume the conversation manually and send a
prompt so Herdr can register it for the next restart.

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
