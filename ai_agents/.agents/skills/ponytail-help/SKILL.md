---
name: ponytail-help
description: >
  Quick reference for ponytail levels, skills and commands. One-shot display.
  Use for /ponytail-help, "ponytail help", "how do I use ponytail".
---

## Codex compatibility

Use `$ponytail-help` to invoke this skill. Resolve tools from those actually available in the current session; never assume Claude plugins or tools exist. Preserve user authorization boundaries.
Claude-specific plugin installation and Band instructions below describe Claude only. For Codex, these folders are installed with GNU Stow through the dotfiles `ai_agents` package; mention skills as `$ponytail`, `$ponytail-review`, etc.


# Ponytail Help

Display this reference card when invoked. One-shot, do NOT change mode,
write flag files, or persist anything.

## Levels

| Level | Trigger | What change |
|-------|---------|-------------|
| **Lite** | `$ponytail lite` | Build what was asked, name the smaller option in one line. |
| **Full** | `$ponytail` | The smallest complete change, a check where the logic needs one, and a reply that names what was skipped and any risk. Default. |
| **Ultra** | `$ponytail ultra` | Also questions the request and pushes back before building. |

Level sticks until changed or session end.

## Skills

| Skill | Trigger | What it does |
|-------|---------|--------------|
| **ponytail** | `$ponytail` | Lazy mode itself: least new code, clear replies that name skipped work and risks. |
| **ponytail-review** | `$ponytail-review` | Quality review of a diff: bugs, security, load, missing tests, speed, what to cut. Each finding says what goes wrong and how to fix it. |
| **ponytail-audit** | `$ponytail-audit` | The same quality review for the whole repo, ranked. |
| **ponytail-debt** | `$ponytail-debt` | Harvest `shortcut:` comments into a tracked ledger. |
| **ponytail-gain** | `$ponytail-gain` | Measured-impact scoreboard: less code, less cost, more speed. |
| **ponytail-help** | `$ponytail-help` | This card. |

In Codex CLI and the IDE extension, invoke skills with `$ponytail`,
`$ponytail-review`, or `$ponytail-help`. Claude Code and OpenCode use the
slash-command forms above (OpenCode ships all six as slash commands).

## Deactivate

Say "stop ponytail" or "normal mode". Resume anytime with `$ponytail`.
`$ponytail off` also works.

## Installation and updates

These are local Codex skills installed by the dotfiles `ai_agents` Stow package.
Update the dotfiles checkout and run `make ai_agents` to refresh their links.
Claude-only Band, session import, automatic plugin updates, and default-mode
hooks are not installed by these instruction files. Activate the desired level
with `$ponytail lite`, `$ponytail full`, or `$ponytail ultra` in the session.

## More

Full docs + examples: https://github.com/DietrichGebert/ponytail
