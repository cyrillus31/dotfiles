---
name: ticket-log
description: Maintain the Jira ticket timeline in the Obsidian vault (tasks/log.md) — when each ticket entered each phase (created, first mentioned, research, planning, implementation, self-fixes, review, review fixes, deploy), what was done, and how long it took. Also rebuilds the log from Jira, GitLab MRs, git and Claude Code transcripts.
when_to_use: A ticket (AISDLC-NNN) was created, first discussed, researched, planned, implemented, self-reviewed, sent to review, fixed after reviewer comments, or merged/deployed — in this session or learned about now. Or the user asks to rebuild, backfill or recount the ticket log (`/ticket-log backfill`, `/ticket-log AISDLC-000`).
---

# Ticket log

File: `~/Documents/Obsidian/cloud_ru/tasks/log.md`
Link: `tasks/log.md` · `obsidian://open?vault=cloud_ru&file=tasks%2Flog`

The log is a record the user shows at performance reviews. A wrong date is worse than a `?`.

## 1. Which tickets belong here

Tickets the user works on: they write code, notes, or reviews for it, or it is assigned to them. A key that only
appears in passing (someone else's branch, a list of epic children) does not get a section — except children of an
epic the user owns, which get a stub (created + first mentioned). When unsure, ask once.

## 2. Phases

Nine phase names, used verbatim in the log. A phase can repeat (review → review fixes → review), so each occurrence
is its own row. Cell markers: exact time; `~` heuristic; `?` happened, time unknown; `—` did not happen.

| Phase | Starts when | Evidence, strongest first |
|---|---|---|
| `ticket created` | the Jira issue exists | Jira `fields.created` |
| `first mentioned` | the key first comes up in the user's work | script `first_mention` (prompt or assistant text; tool output ignored) |
| `research` | work on understanding the problem starts | first attributed session activity before any plan or code (script `first_activity`); first edit of a problem/spike/explained note; Jira → `Development` |
| `planning` | a solution is being designed | script `first_plan_mode`; birth time of a `~/.claude/plans/*.md` naming the key (`stat -f %SB`); first edit of a `*spec*`/`*plan*`/`*decision*` note |
| `implementation` | code for the ticket is written | min(script `first_code_edit`, `first_commit`) |
| `self-fixes` | the user reviews their own code and fixes findings | script `self_review_prompts` (`/code-review`, `/simplify`, code-critic, "self-review") → time of the first commit after it; `*self_review*`/`*code_review_findings*` notes |
| `review` | the MR is handed to humans | MR `created_at` if created non-draft; else system note `marked this merge request as **ready**`; else `requested review from @…` |
| `review fixes` | the user pushes changes answering a reviewer | first system note `added N commit` after the first non-author, non-bot, non-system note on that MR |
| `deploy` | the MR is merged into `main` | MR `merged_at`; Jira → `Deployment` corroborates. One row per MR |

Rules:
- Several MRs (backend + frontend) → `review` / `review fixes` / `deploy` rows per MR, naming the MR in evidence.
- Self-review after a review round is still `self-fixes`; tell it from `review fixes` by who raised the finding.
- Bots are not reviewers (`GitLab-Security-Bot`, bodies starting with `<!--`).
- Never overwrite an exact time with a heuristic one. An exact time may replace a `~`/`?` cell — say so in chat.
- A commit's author date survives rebases; the push time is the MR system note `added N commit`.

## 3. Layout of `log.md`

Russian prose (vault convention, `tasks/AGENTS.md` §1). Phase names, MR/commit ids and quotes stay as they are.
Tickets ordered by latest activity, newest first. Use `Edit` on the file; never rewrite sections you did not change.

```markdown
#copilot

# Журнал тикетов

> Время — МСК. `~` — эвристика, `?` — было, время неизвестно, `—` — не было.
> **Активно** — оценка снизу: промпты в Claude Code и свои коммиты, ≤30 мин друг от друга, сливаются в блок, +15 мин
> к концу блока; минуту, где открыто несколько тикетов, делят поровну; в сутки не больше 8 ч. Работа вне Claude
> (чтение кода в редакторе, созвоны) не видна. **Рабочих дней** = Активно / 8.

## Сводка

| Тикет | Суть | Фаза сейчас | Начало | Deploy | Календарно | Активно | Рабочих дней |
|---|---|---|---|---|---|---|---|
| [[AISDLC-000 (example)/00_index\|AISDLC-000]] | Пример: починили гонку при отмене задачи | deploy · Jira: Deployment | Пт 01.01 | Ср 06.01 | 4,9 дн | 14,2 ч | 1,8 |

## AISDLC-000 — <summary из Jira дословно>

**Суть:** одно-два предложения: что было сломано или нужно, и кому от этого плохо.

**Что сделано:**
- пункт с MR/коммитом: [MR!1](<ссылка на MR>)

| Фаза | Когда | Доказательство |
|---|---|---|
| ticket created | Пт 01.01.2026 17:20 | Jira |
| review | Пн 04.01.2026 15:11 | MR!1 marked as ready |
| review fixes | Вт 05.01.2026 11:57 | MR!1: `abcdef01` после комментария @reviewer 04.01 22:16 |

**Итог:** календарно 4,9 дн (Пт 01.01 → Ср 06.01); активно ≈ 14,2 ч = 1,8 рабочих дня из 8-часовых; из них 2,2 ч
параллельно с другими тикетами; дни с активностью: Пт 01.01 (0,1 ч), Пн 04.01 (6,4 ч), Вт 05.01 (7,4 ч), Ср 06.01 (0,3 ч).
```

- Link the ticket to its vault folder index when one exists (folder names may carry a suffix — `ls` first).
- Epics: `Итог` = own direct hours + a line listing children with their hours; do not add children into own hours.
- A ticket not yet started: `ticket created`, `first mentioned`, `Фаза сейчас` = Jira status, no `Итог`.
- Numbers use a decimal comma. Dates in `Сводка` are short (`Пт 11.09`), in phase tables full (`Пт 11.09.2026 17:20`).

## 4. Live update (the common case)

1. Identify ticket and phase from what just happened. If it happened now, time = now:
   `python3 -c "from datetime import datetime as d; n=d.now(); print('ПнВтСрЧтПтСбВс'[2*n.weekday():2*n.weekday()+2], n.strftime('%d.%m.%Y %H:%M'))"`
   If learned after the fact, fetch the real time from the source (§6); never stamp "now" on a past event.
2. Read `log.md`. Skip if a row with the same phase and evidence exists.
3. Add the row; update `Фаза сейчас`, `Что сделано`, and the ticket's position in `Сводка`.
4. Recount `Итог` only when the ticket reaches `deploy`, or when the user asks: run the script (§5), then write
   `Итог` and append `(зафиксировано DD.MM.YYYY)`. A frozen `Итог` is not recounted — transcripts expire.
5. Tell the user in one line: ticket, phase, time, and the link.

## 5. Effort script

```bash
python3 ~/.claude/skills/ticket-log/scripts/ticket_effort.py AISDLC-000 AISDLC-001 \
  --alias my-feature-branch-name=AISDLC-000 --json
```

Scans all transcripts (~25 s): run it once per update with every key needed, not once per key. Parallel splitting
and the 8 h cap are computed over every AISDLC key seen, so the numbers for one key do not change with which keys
are requested.

Output per key: `firsts.{first_mention, first_plan_mode, first_note_edit, first_code_edit, first_commit}` (each
`at`, `iso`, `detail`), `self_review_prompts[]`, `merges_into_main[]` (from local `origin/main`, may be stale — GitLab
`merged_at` wins), `first_activity`, `last_activity`, `calendar_span_days`, `active_hours`, `workdays`,
`overlap_hours`, `active_days[]`.

Flags: `--debug-day YYYY-MM-DD` prints every ticket's activity blocks that day — use it before trusting a surprising
number. `--email` adds an author identity; `--repo` adds a repo; `--idle-min`, `--tail-min`, `--day-cap-h` tune the model.

How a prompt gets its ticket: keys in its text → key in the session's `gitBranch` or `cwd` basename (worktrees like
`agent-aisdlc-571`) → the nearest keyed prompt in the same stretch of the session (a >2 h pause starts a new stretch).
A code edit belongs to the ticket of the prompt before it. Commits count only when authored by the user (each repo's
`git config user.email` plus `kofedtsov@cloud.ru`; `~/Projects/copilot/agent` commits as `Test <test@example.com>`).
A keyless commit belongs to the ticket named by its branch; with stacked branches, the shortest branch claims it.

Known blind spots, to state rather than hide:
- Sessions attributed to the wrong ticket when one session touches several without naming them.
- Transcripts are deleted after `cleanupPeriodDays` (set to 365 in settings); older effort is gone.
- Research folders and branches not named after the key need `--alias <text>=<KEY>`, e.g.
  `--alias my-feature-branch-name=AISDLC-NNN`. Check `tasks/log.md` (private, not in git) for which aliases are
  currently in use rather than re-deriving them from memory.

## 6. Data sources

**Jira** (`atlassian-jira` MCP):
- `jira_get_issue` → `summary`, `status`, `created`, `assignee`, `issuetype`, parent/epic.
- `jira_batch_get_changelogs` → status transitions with timestamps (statuses seen: `Сделать`, `Development`,
  `Deployment`, `Сделано`).
- If the MCP is not connected, leave `ticket created` as `?` and say so; do not guess it from the vault.

**GitLab** (self-hosted; follow the `gitlab` skill for auth and host; pass `--hostname <host>` outside a repo):
```bash
P=<url-encoded-project-path>        # e.g. group%2Fsubgroup%2Fproject; one per repo in DEFAULT_REPOS
glab api "projects/$P/merge_requests?state=all&search=AISDLC-000&per_page=100"
glab api "projects/$P/merge_requests/1"   # created_at, draft, merged_at, source_branch
glab api "projects/$P/merge_requests/1/notes?sort=asc&per_page=100"
```
In notes: `system: true` + body `marked this merge request as **ready**` → review; `requested review from @x` → review;
`added N commit` → a push (the commit ids are in the body); `approved this merge request`; non-system notes by someone
other than the MR author (and not a bot) → reviewer comments. MR search misses MRs whose title and description lack
the key — also look up local branches (`git -C ~/Projects/copilot/agent branch -a | grep -i AISDLC-000`) and query
`merge_requests?source_branch=<branch>`, and check MR links in the ticket's vault notes.

**Vault**: the ticket folder's `00_index.md` has the summary, MR links and dated status lines (`DD.MM.YYYY`) — use them
for `Суть`, `Что сделано`, and as corroboration. Note file times are unreliable (folders get consolidated).

## 7. Backfill (`/ticket-log backfill`)

1. Scope: folders `tasks/AISDLC-*` plus their epic's children, per §1. List the keys to the user before fetching.
2. Jira for every key (issue + changelog), GitLab MRs and notes for every key, one script run for all keys (`--json`),
   `00_index.md` of every folder.
3. Build every ticket's phase rows from §2, write the whole file, then read it back once to check tables render
   (pipes escaped in wikilinks, one row per line).
4. Report in chat: per ticket, which phases are `~` or `?` and why, and anything contradictory (e.g. vault says
   merged, GitLab says open).
