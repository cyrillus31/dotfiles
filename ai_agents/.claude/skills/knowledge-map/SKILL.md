---
name: knowledge-map
description: Maintain a knowledge map of how well the reader grasps each topic — per-topic scores from 0 to 100 plus a criticality rating, split into transferable theory subjects and project-specific files, updated from the quality of their questions and answers, and used to decide how much explanation a topic still needs.
when_to_use: An exchange revealed something about how well the reader understands a topic — a question that showed a gap or a firm grasp, an answer to a direct question, a correction they made. Or the user asks to read, rebuild, or adjust the knowledge map (`/knowledge-map`, `/knowledge-map <topic>`).
---

# Knowledge map

Plain markdown under the agent's own config directory — **no Obsidian, no vault, no external tool**:

```
~/.claude/knowledge_map/
  knowledge.md              index: what is tracked and where. No scores, no rules.
  theory/<subject>.md       one file per transferable subject — go.md, python.md, sql.md, kubernetes.md
  projects/<project>.md     one file per project
```

- **`knowledge.md` is the index.** It lists every subject and project with a one-line description and a link. Read it first; it is cheap and it tells you which file to open.
- **One subject or one project per file.** `theory/` holds what would still be true at another company; `projects/` holds what is true only here. Create a file the first time a subject or project comes up substantively, and add it to the index in the same edit.
- **The rules live in this skill (§1-§5), and no file in the map copies them** — at most a one-line pointer here. The map is per-user data and the skill is shared and versioned; a copy in both drifts.
- A file that has grown past comfortable reading gets split, with the index updated.

Everything is ordinary markdown tables — readable with `cat`, editable by hand, and portable to any machine that has the skill.

## 0. What this map is protecting

Two competences, and both decay silently when an agent does the work — the output keeps looking fine while the understanding behind it thins out:

1. **The transferable fundamentals, at interview depth.** `theory/` holds these, and they are most of the high-criticality rows.
2. **The ability to explain the reader's own work, and why it is built the way it is.** Shipping something with an agent's help and being able to defend its design six months later are different skills, and only the first happens by itself. `projects/` holds these — and the theory underneath a decision belongs to that row rather than a separate one: "why a row lock here instead of a lease" is the project topic, not merely "what a row lock is".

The working test for the second: **could the reader write the whole thing out from memory** — the problem, why the naive fixes break, why this design won, what it cost — without rereading the work? That is precisely what an interviewer means by "walk me through something you built". If the answer is no, that work scores low no matter how smoothly it shipped.

## 1. What a topic is

One row per topic, and **granular beats broad**. "Базы данных" is not a topic. "Postgres row-level locking (`SELECT ... FOR UPDATE`)" is. If a score would mean different things for two parts of a row, it is two rows.

Topics live at every altitude, and all of them belong in the map:

| Altitude | Example |
|---|---|
| concept | optimistic concurrency — why a compare-and-swap beats a lock under low contention |
| mechanism | Postgres row-level locking: what `SELECT ... FOR UPDATE` actually holds, and until when |
| concrete entity | the `owner` column on the `runs` table — what it stores, what it is for, why it is not a lease |

The lowest altitude is a knowledge point in its own right, not a detail of a bigger one. What a specific column means and where it is stored is exactly what turns out to be missing when something breaks at 2am.

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

## 3. Criticality

Every topic also carries a criticality, and it answers a different question from the score. The score says *how well the reader knows it*. Criticality says *what it costs them not to*.

The measure is deliberately not "how much does this matter for shipping the current ticket" — an agent ships the ticket either way. It is: **how much does not knowing this hollow out the reader as an engineer?** They are building with agents full-time, which means understanding can quietly decay while the output stays fine, and the bill arrives later — in an interview, or the first time something breaks that no agent can be pointed at. Rate accordingly.

| Criticality | What it covers | Test |
|---|---|---|
| высокая | transferable fundamentals: why a race happens, what a lock actually holds, transaction isolation, concurrency primitives, complexity reasoning | an interviewer at another company would ask this, and no amount of looking it up mid-answer saves you |
| средняя | mechanisms worth holding but recoverable from docs under pressure: library behaviour, framework patterns, tooling | you could rebuild it from the docs in an hour, and partly transfers elsewhere |
| низкая | project-local facts, names, config values, where something is written down | nobody outside this codebase will ever ask, and looking it up is always cheaper than memorising it |

**The asymmetry worth catching:** a concrete project entity is usually низкая, while the *pattern it instantiates* is высокая. Nobody will ever ask what the `owner` column on `runs` holds. They will ask how you would stop two replicas from killing each other's jobs — and that is the same knowledge, at the altitude that transfers. When a low-criticality entity is an instance of a high-criticality pattern, put both in the map and say which is which. This is `Teaching`'s rule that abstract principles don't transfer but recognisable silhouettes do, applied to what is worth scoring.

### The quadrant that makes this actionable

Score and criticality are only useful crossed:

| | low score | high score |
|---|---|---|
| **высокая criticality** | **the blindspot that matters** — the whole reason this map exists; close these first | fine, keep it warm |
| **низкая criticality** | ignore, look it up when it comes up | fine, no action |

And a consequence, not just a rating: when a topic is высокая and the score is low, don't simply hand over the finished answer — that is the exact transaction that produced the gap. Walk the reasoning, per `Teaching`, and say plainly that this one is worth actually holding.

## 4. What each band means in practice

This is the point of the map — it decides how much explanation a topic gets:

| Band | Treat the topic as |
|---|---|
| 0-39 | brand new: full teach-by-failure, every name decoded, the 3-5x repetition `Repeat yourself, on purpose` asks for |
| 40-69 | known in outline: explain the mechanism, skip first principles, still decode names |
| 70-89 | solid: reference it directly, explain only the non-obvious corner actually in play |
| 90-99 | strong: use it as shorthand, explain nothing unless asked |
| 100 | confirmed: no explanation at all — but only after §5 |

## 5. Reaching 100

When a topic would hit 100, **do not silently stop explaining it.** Tell the reader it reached 100 and ask whether to switch explanations off for it. Hold it at 99 until they confirm.

The reason: a score can inflate on a couple of good questions, and a silent switch-off means losing explanations without ever knowing why they stopped. CLAUDE.md's rule is to define terms "until I tell you I've got it" — the reader telling is the trigger, not an inference from a counter. The confirmation is what converts the counter into that signal.

Once confirmed, mark the row `100 ✓ подтверждено` with the date.

## 6. When to update

There is no background process — an agent only acts during a turn. "Automatic" here means: update without being asked, in the same turn the evidence appeared, as a normal file edit. It is a visible write, not an invisible one.

- Update when an exchange actually revealed something. Not every message does; most don't.
- Batch within a turn: one edit covering every topic the exchange touched, not one edit per topic.
- Don't announce routine updates. A score moving from 55 to 60 is not worth a line of the reader's attention — §4's confirmation and a genuine reversal (a topic dropping a band) are the exceptions worth mentioning.

## 7. Working with a walkthrough

A `walkthrough` skill, if one is installed, is the single richest source of evidence this map can get: it asks graded comprehension questions and sees exactly which ones land. There is no declared dependency between the two skills — a standalone `SKILL.md` has no `dependencies` field — so the link is simply that each checks whether the other is listed and uses it when it is.

- **Before a walkthrough starts**, it should read the relevant subject or project file and pick its opening depth from the band (§4) instead of assuming zero context. A topic already at 75 does not need teaching from scratch.
- **After each graded check**, the walkthrough has precisely what §2 wants: a question, an answer, and a verdict on the reasoning. Record the move and the evidence.
- Batch the writes. One edit at the end of a walkthrough, or at a natural pause, beats an edit after every question.
- If no walkthrough skill is installed, nothing here applies and the map works exactly as before.

## 8. Reading the map

Before explaining anything substantial, the relevant topic's band (§4) sets the depth. When the map and the evidence in front of you disagree — the reader asks something that a 90 wouldn't ask — trust the evidence, explain accordingly, and move the score in the same turn. The map is a record of past evidence, never a reason to ignore present evidence.
