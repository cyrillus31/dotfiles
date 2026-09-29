---
name: interactive-walkthrough
description: Run a chat-based, step-by-step walkthrough toward a stated learning goal — teaches any amount of new material in small comprehension-gated chunks, states the whole plan up front, delivers one short chunk at a time, checks understanding before advancing, and recalibrates depth as the reader's real level shows itself. Requires a goal argument: what the reader should understand and still remember when it ends.
when_to_use: The user asks to be walked through, taught, or onboarded to a topic interactively, asks for a step-by-step/guided explanation, or invokes `/interactive-walkthrough <goal>`.
---

# Interactive walkthrough

This is the explicit, packaged form of the "one step at a time" mode CLAUDE.md's `Complex topics: lay it all out` section allows as an opt-in — here it's the default for the whole session, not a one-off request. Apply CLAUDE.md's `Teaching`, `Tone`, `Repeat yourself, on purpose`, `Decode the names`, and the precision-over-abstraction bullet at the top of `Rules` to every chunk below; this skill only adds the structure around them.

## 1. Opening message

**The goal is a required argument.** A walkthrough is defined by what the reader should be able to explain, and still remember, when it ends — not by which topic gets covered. If the invocation carried no goal (`/interactive-walkthrough` with nothing after it, or a bare topic name like "langgraph"), ask for it and start nothing until it's answered: what should the reader walk away knowing? Inventing a goal from a bare topic is a guess, and every later decision is derived from it — which steps exist, what each chunk covers, which questions gate it, and what the ending checks.

Then, before any teaching content:

1. **The goal, restated.** One or two lines in your own words, so the reader can correct the target before any effort is spent aiming at the wrong one.
2. **The problem, precisely.** State what the problem actually is, why it exists at all (a real constraint or a real failure mode, not an invented one), and why the obvious/naive fix doesn't work. This is `Teaching`'s "answer the first objection" and "teach by failure first" rules, applied as the walkthrough's frame before any step begins.
3. **The full agenda.** List every planned step, one line each, each named for what it contributes to the goal, so the shape of the whole walkthrough is visible before starting — same reasoning as `Complex topics: lay it all out`'s "say up front how many parts there are," delivered as a table of contents instead of inline steps.
4. Immediately follow with chunk 1 in the same message — don't stop to ask permission to begin.

Start assuming **zero context and junior-or-below technical competence**, regardless of how the reader has come across earlier in the session — a specific topic can be one they've never touched even if others weren't. Don't ask "what's your level?" up front; §5 is the actual instrument for measuring it.

## 2. Each chunk

- **Length:** roughly 150-400 words — a 1-3 minute read. If a step genuinely needs more, split it into two chunks rather than stretch the read.
- **No Mermaid in plain chat.** Claude Code's terminal doesn't render Mermaid — assume that's the medium unless the walkthrough is explicitly landing in something that renders it (an Obsidian note, a claude.ai Artifact). Use an ASCII diagram instead when a diagram earns its place.
- Every sentence describing a mechanism must be precise, never abstract: name the actual database row/column, network request/response field, or code-level construct involved — never a metaphor or an anthropomorphized stand-in for the literal fact (`Rules`, top bullet). Short is not an exemption from this.
- Never mention an entity ("the user", "the run", "the ticket") without saying which representation of it is meant — the row and which columns, the in-code object and which fields, or the identifier used as a foreign key elsewhere. This is the bare entity reference `Rules` bans, and a walkthrough introducing a new entity is exactly where it's most tempting to skip.
- Give every entity its address too — which database and table, which service, which repo or file — and repeat that address on the next few mentions rather than only the first. A walkthrough is where an entity is met for the very first time, so the address has to land here or it never will.
- Every chunk still gets a concrete, real-valued example — an abstract statement of the rule alone never counts as the explanation.
- Assume zero context for each new concept the first time it appears, regardless of how technical the reader has seemed on other topics. Once introduced, anything genuinely complex or non-self-evident gets restated, in different phrasing, three to five times across the walkthrough — including whenever it resurfaces in a later chunk, not only within the chunk that first defined it — before assuming it's actually landed. An already-obvious fact still gets one sentence; this is for what's actually hard, not everything. The categories `Repeat yourself, on purpose` marks as automatically complex — non-trivial SQL, transactions, and anything async/concurrent/parallel — always qualify here, no judgement call.
- **End every chunk with 1-3 check questions** — see §3.

## 3. Comprehension check

What these questions are for: confirming the reader understands the problem this chunk covers, from more than one angle, and understands why the proposed solution was built the way it was — not confirming they can recall what the chunk just said. They are not memory-recall quizzes, not gotcha or trick questions, and not hypothetical-imagination exercises ("what if X changed instead"). A good question is one that narrows the reader — and the walkthrough — down to the one or two points in the chunk that actually matter, and confirms specifically those landed.

- Ask 1-3 such questions per chunk, aimed at the problem and the reasoning behind the solution, never at wording recall or trivia.
- **Design test: a correct answer should be possible only two ways — the reader read and understood this chunk, or they already knew the material.** If a question can be answered by skimming, by general programming knowledge, by common sense, or by guessing from how the question itself is worded, it is testing nothing — rewrite it. And when a reader does answer correctly without having read the chunk, that isn't the check failing; it's the signal §5 acts on, that the level was pitched too low for them.
- **Cover each crucial point, not the gist.** Reading a chunk, following 90% of it, and missing the one part that actually carries the weight is the common failure — and a question aimed at the overall shape of the chunk waves that reader straight through. Aim each question at a specific load-bearing point, and aim it where someone who skimmed *that particular part* would go wrong: the exact column, the exact ordering, the exact failure mode — not the headline the chunk was about.
- That design test does not conflict with the refresher §4 attaches to every restated question. The refresher repeats the *setup* — which entity, which field, which mechanism is in play — so the reader isn't hunting for context they already read once. The question asks for the *connection between those facts*, which no two-line refresher can hand over. Facts can be restated; understanding can't.
- Wait for an answer before moving on. Don't advance the walkthrough in the same message as the questions.
- Grade generously on wording, strictly on substance — and substance means the reasoning, not just the conclusion. A right-sounding answer can still be a guess; a guess and real understanding produce the same words. If the first answer states the conclusion without the reasoning behind it, ask one quick follow-up ("why") before deciding pass or fail — that follow-up is what tells a guess from a grasp, and it's a single quick check, not the re-explanation round below.
- A broadly-right answer that is silent on, or wrong about, the crucial part is a miss, not a pass. "Generous on wording" never means filling the missing piece in on the reader's behalf because everything around it sounded right — probe exactly the part they skipped. When that confirms the gap, the re-explanation (🔁) targets only the missing piece, not the whole chunk: someone who had 90% doesn't need the 90% again, and re-teaching it reads as not having listened to their answer.
- Only advance once the reasoning holds up, not just the stated conclusion. Treat missing, evasive, or contradicted reasoning the same as a wrong answer: re-explain the point from a different angle (`Repeat yourself, on purpose` — a different angle, not the same sentence again), then re-ask, before moving on.
- Don't turn this into an exam. One full clarifying round (re-explain + re-ask) per genuine miss is normal; if it's still not landing after that, the chunk itself was pitched wrong — rewrite it, don't keep re-testing the same explanation.

**The questions are a gate, not a suggestion — once asked, they stay open regardless of what happens next in the conversation.** If the reader goes on a tangent, asks something unrelated, or asks about something else entirely, that does not clear the open questions: answer what they actually asked, then return to the still-open questions before advancing. Never let the walkthrough drift into the next chunk just because the conversation moved elsewhere. The only way past an open question, besides answering it, is the reader explicitly or clearly-implicitly asking to skip it ("skip this", "let's just move on") — absent that, there is no other path forward.

## 4. Status recap and visual markers

Every response while a walkthrough is running — not only the ones delivering a new chunk — opens with a short status block, so the reader never has to scroll up to work out where they are — a walkthrough can sit open for hours while they're pulled onto other work, and this block is what lets them resume cold — and so a walkthrough response is distinguishable from ordinary chat at a glance:

```
🎓 Walkthrough · 🎯 <goal, one short line> · 📍 Step 2 of 5 — <step name> · 1/3 answered
✅ Q1: <question, one line> — you said X, so <one-line reinterpretation of what that established>.
❓ Q2: <question, one line> — still open. <the facts needed to answer it, one or two lines>.
❓ Q3: <question, one line> — still open. <the facts needed to answer it, one or two lines>.
```

- Include it even when the response is answering a side question, clarifying a term, or handling a tangent — not only when the walkthrough itself advances.
- A clarifying question about the current chunk means the reader stopped reading at that point — the rest of that chunk is probably still unread. Answer it, then hand them back to the exact spot they stopped at. A clarification never counts as having cleared the chunk, and never advances the walkthrough to the next step.
- Never answer anything blindly: name which question this response is addressing — the reader's side question, or which of the open check questions their answer landed on — re-posed in cleaner words than it was asked in, before answering it. The block shows what's *open*; this shows what's being *dealt with right now*. A reader who has been away, or who fired off three things at once, must never have to work out which one just got answered.
- **Every restatement of an open question carries the information needed to answer it** — the relevant mechanism, the entity and field names in play, the setup the question is about — so the reader can answer from the block alone without scrolling back to the chunk. Not the answer itself, and not the chunk re-pasted: the general facts that lead to the answer, one or two lines. Repeating the conclusion the question is testing makes the check worthless; repeating nothing makes the reader hunt for context they already paid attention for once.
- An answered question's line is not just a checkmark: restate in one line what the reader's answer actually established. That does double duty as the repeated confirmation `Repeat yourself, on purpose` already asks for, rather than costing anything extra.
- When a step's questions are all answered or explicitly skipped (§3) and the next chunk starts, the block resets to that chunk's own questions — a resolved step's questions don't get carried forward.
- This is exactly why chunks in §2 stay small: the block repeats on every message for as long as a step's questions are open, so a bigger step means paying for its recap more times and for longer. Small steps keep the recap a small fraction of each response instead of the bulk of it.

These glyphs carry fixed meanings and are used consistently for the whole walkthrough:

| Glyph | Means |
|---|---|
| 🎓 | walkthrough mode is active — opens the status block |
| 🎯 | the goal (§1) |
| 📍 | the current step |
| ✅ | question answered and accepted |
| ❓ | question still open |
| 🔁 | re-explaining after a missed check (§3) |
| ⚠️ | agenda or pacing change (§5, §6) |
| 🏁 | walkthrough complete (§7) |

- They are status signals, not decoration. The teaching prose in each chunk stays plain, precise text per §2 — a walkthrough that sprinkles emoji through its explanations is worse than one with none.
- Keep the set fixed. Inventing a new glyph mid-walkthrough defeats the point: the reader learns these eight once and can then parse any response without reading it closely.
- This is scoped to walkthrough mode. Outside it, the normal no-emoji default applies.

## 5. Recalibrating the level as you go

- Read each answer for more than correct/wrong: precise unprompted vocabulary, a caught edge case, a question that skips ahead — all of that means the assumed level was too low. A vague or only-partially-right answer that just echoes the words just given back means the level is about right, or still too high.
- Adjust the next chunk's depth and pace, not just its content: skip re-deriving fundamentals the reader has already shown they have, use denser language, or fold two planned chunks into one — or the reverse, smaller chunks and more repetition, if answers are struggling.
- Say so once, briefly, the first time a real shift happens ("you clearly already know X, so I'll skip re-deriving Y and move faster from here") — the same no-silent-deviation principle as §6, applied to pacing instead of content. Don't narrate a running commentary on every question's grade.

## 6. Changing the agenda mid-walkthrough

Finding out partway through that a step is missing, needs splitting, or needs reordering is normal, not a failure — the agenda from §1 is a plan, not a contract. When it happens: say so explicitly before delivering the changed content ("this needs one more step than planned, because X"), update the visible agenda, then continue. Never insert or reorder a step silently — that's the mental-model-reversal `Rules` already bans, applied here to the walkthrough's own shape.

## 7. Ending

Close by answering the goal from §1 directly: state what the reader can now explain that they couldn't at the start, and name anything in the goal that wasn't reached rather than letting it pass silently. Then a short recap: the central problem from §1, the one or two central conclusions (`Teaching`'s rule on calling out the central problem(s) first), and the general principle this was an instance of. Write this recap as if it might get pasted somewhere and stand alone — that's the same bar `The opening paragraph is a triage test` sets for what a future revisit of this material should find.
