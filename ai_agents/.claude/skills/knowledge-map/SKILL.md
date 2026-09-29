---
name: knowledge-map
description: Maintain the reader's knowledge map in the Obsidian vault — per-topic scores from 0 to 100 estimating how well they grasp each topic, split into a general CS/theory file and a project-specific file, updated from the quality of their questions and answers, and used to decide how much explanation a topic still needs.
when_to_use: An exchange revealed something about how well the reader understands a topic — a question that showed a gap or a firm grasp, an answer to a direct question, a correction they made. Or the user asks to read, rebuild, or adjust the knowledge map (`/knowledge-map`, `/knowledge-map <topic>`).
---

# Knowledge map

Two files in the vault, one directory:

- `knowledge/theory.md` — topics that exist outside this project: SQL, transactions, concurrency, HTTP, data structures, Python, Go, Kubernetes, testing. Anything that would still be true at a different company.
- `knowledge/project.md` — topics that exist only here: the copilot/agent architecture, its surfaces, its decisions and their reasons, its dependencies and how they interact, ticket history that still shapes the code.

Both follow the vault's own `tasks/AGENTS.md`: Russian prose, `# Title` heading, no YAML frontmatter, code identifiers and paths verbatim. The maintenance rules live inside each file as a blockquote legend, the same way `tasks/log.md` carries its own legend — so the file explains itself to someone opening it cold months later.

## 1. What a topic is

One row per topic, and **granular beats broad**. "Базы данных" is not a topic. "Postgres row-level locking (`SELECT ... FOR UPDATE`)" is. If a score would mean different things for two parts of a row, it is two rows.

A topic enters the map the first time it comes up in conversation in any substantive way — not only when the reader asks about it. Anything either side treats as load-bearing for the work qualifies.

## 2. Scoring

Every topic starts at **50/100** — assumed neither known nor unknown.

Scores move on evidence, and **only on evidence about grasp, never on question count**. A reader asking many sharp questions about a topic usually understands it *better* than one asking none; volume is not the signal, and treating it as one would invert the whole map.

| Signal | Move |
|---|---|
| A question that shows a specific gap, a wrong premise, or a confusion of two things | −5 |
| An answer to a direct question that misses the load-bearing part | −10 |
| A question that shows the mechanism is understood and probes a real edge of it | +5 |
| An answer that reconstructs the reasoning unprompted, or a correction the reader makes that turns out right | +10 |

- At most one move per topic per exchange. A long exchange that reveals the same gap four times is one −5, not −20.
- Every move records **what revealed it**, in the row. A bare number is unfalsifiable and unreviewable; "−5, перепутал `FOR UPDATE` и `FOR SHARE`" can be argued with.
- Never move a score on a guess about what the reader probably knows. No evidence, no move.

## 3. What each band means in practice

This is the point of the map — it decides how much explanation a topic gets:

| Band | Treat the topic as |
|---|---|
| 0-39 | brand new: full teach-by-failure, every name decoded, the 3-5x repetition `Repeat yourself, on purpose` asks for |
| 40-69 | known in outline: explain the mechanism, skip first principles, still decode names |
| 70-89 | solid: reference it directly, explain only the non-obvious corner actually in play |
| 90-99 | strong: use it as shorthand, explain nothing unless asked |
| 100 | confirmed: no explanation at all — but only after §4 |

## 4. Reaching 100

When a topic would hit 100, **do not silently stop explaining it.** Tell the reader it reached 100 and ask whether to switch explanations off for it. Hold it at 99 until they confirm.

The reason: a score can inflate on a couple of good questions, and a silent switch-off means losing explanations without ever knowing why they stopped. CLAUDE.md's rule is to define terms "until I tell you I've got it" — the reader telling is the trigger, not an inference from a counter. The confirmation is what converts the counter into that signal.

Once confirmed, mark the row `100 ✓ подтверждено` with the date.

## 5. When to update

There is no background process — an agent only acts during a turn. "Automatic" here means: update without being asked, in the same turn the evidence appeared, as a normal file edit. It is a visible write, not an invisible one.

- Update when an exchange actually revealed something. Not every message does; most don't.
- Batch within a turn: one edit covering every topic the exchange touched, not one edit per topic.
- Don't announce routine updates. A score moving from 55 to 60 is not worth a line of the reader's attention — §4's confirmation and a genuine reversal (a topic dropping a band) are the exceptions worth mentioning.

## 6. Reading the map

Before explaining anything substantial, the relevant topic's band (§3) sets the depth. When the map and the evidence in front of you disagree — the reader asks something that a 90 wouldn't ask — trust the evidence, explain accordingly, and move the score in the same turn. The map is a record of past evidence, never a reason to ignore present evidence.
