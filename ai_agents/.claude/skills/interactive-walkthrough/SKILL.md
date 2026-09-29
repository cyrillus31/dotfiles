---
name: interactive-walkthrough
description: Run a chat-based, step-by-step walkthrough that teaches any amount of new material in small comprehension-gated chunks — states the whole plan up front, delivers one short chunk at a time, checks understanding before advancing, and recalibrates depth as the reader's real level shows itself.
when_to_use: The user asks to be walked through, taught, or onboarded to a topic interactively, asks for a step-by-step/guided explanation, or invokes `/interactive-walkthrough <topic>`.
---

# Interactive walkthrough

This is the explicit, packaged form of the "one step at a time" mode CLAUDE.md's `Complex topics: lay it all out` section allows as an opt-in — here it's the default for the whole session, not a one-off request. Apply CLAUDE.md's `Teaching`, `Tone`, `Repeat yourself, on purpose`, `Decode the names`, and the precision-over-abstraction bullet at the top of `Rules` to every chunk below; this skill only adds the structure around them.

## 1. Opening message

Before any teaching content:

1. **The problem, precisely.** State what the problem actually is, why it exists at all (a real constraint or a real failure mode, not an invented one), and why the obvious/naive fix doesn't work. This is `Teaching`'s "answer the first objection" and "teach by failure first" rules, applied as the walkthrough's frame before any step begins.
2. **The full agenda.** List every planned step, one line each, so the shape of the whole walkthrough is visible before starting — same reasoning as `Complex topics: lay it all out`'s "say up front how many parts there are," delivered as a table of contents instead of inline steps.
3. Immediately follow with chunk 1 in the same message — don't stop to ask permission to begin.

Start assuming **zero context and junior-or-below technical competence**, regardless of how the reader has come across earlier in the session — a specific topic can be one they've never touched even if others weren't. Don't ask "what's your level?" up front; §4 is the actual instrument for measuring it.

## 2. Each chunk

- **Length:** roughly 150-400 words — a 1-3 minute read. If a step genuinely needs more, split it into two chunks rather than stretch the read.
- **No Mermaid in plain chat.** Claude Code's terminal doesn't render Mermaid — assume that's the medium unless the walkthrough is explicitly landing in something that renders it (an Obsidian note, a claude.ai Artifact). Use an ASCII diagram instead when a diagram earns its place.
- Every chunk still gets a concrete, real-valued example and the precise-first framing — short is not an exemption from either.
- **End every chunk with 1-3 check questions** — see §3.

## 3. Comprehension check

- Ask 1-3 questions that test the one or two operative facts of that specific chunk — not trivia, not something answerable without having understood the point. Prefer a question that makes the reader apply the fact to a new instance (predict what happens if X changes) over one that just asks them to repeat a definition back.
- Wait for an answer before moving on. Don't advance the walkthrough in the same message as the questions.
- Grade generously on wording, strictly on substance: if the reader has the operative fact even in their own words, that's a pass — move to the next chunk. If the answer is missing or contradicts the fact, re-explain it from a different angle (`Repeat yourself, on purpose` — a different angle, not the same sentence again), then re-ask before moving on.
- Don't turn this into an exam. One clarifying round per miss is normal; if it's still not landing after that, the chunk itself was pitched wrong — rewrite it, don't keep re-testing the same explanation.

## 4. Recalibrating the level as you go

- Read each answer for more than correct/wrong: precise unprompted vocabulary, a caught edge case, a question that skips ahead — all of that means the assumed level was too low. A vague or only-partially-right answer that just echoes the words just given back means the level is about right, or still too high.
- Adjust the next chunk's depth and pace, not just its content: skip re-deriving fundamentals the reader has already shown they have, use denser language, or fold two planned chunks into one — or the reverse, smaller chunks and more repetition, if answers are struggling.
- Say so once, briefly, the first time a real shift happens ("you clearly already know X, so I'll skip re-deriving Y and move faster from here") — the same no-silent-deviation principle as §5, applied to pacing instead of content. Don't narrate a running commentary on every question's grade.

## 5. Changing the agenda mid-walkthrough

Finding out partway through that a step is missing, needs splitting, or needs reordering is normal, not a failure — the agenda from §1 is a plan, not a contract. When it happens: say so explicitly before delivering the changed content ("this needs one more step than planned, because X"), update the visible agenda, then continue. Never insert or reorder a step silently — that's the mental-model-reversal `Rules` already bans, applied here to the walkthrough's own shape.

## 6. Ending

Close with a short recap: the central problem from §1, the one or two central conclusions (`Teaching`'s rule on calling out the central problem(s) first), and the general principle this was an instance of. Write this recap as if it might get pasted somewhere and stand alone — that's the same bar `The opening paragraph is a triage test` sets for what a future revisit of this material should find.
