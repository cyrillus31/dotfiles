---
name: walkthrough
argument-hint: "<goal: what you should understand by the end>"
description: Run a chat-based, step-by-step walkthrough toward a stated learning goal — teaches any amount of new material in small comprehension-gated chunks, each carrying the bare minimum needed to answer its check questions, while the questions together cover the whole goal; states the whole plan up front, delivers one short chunk at a time, checks understanding before advancing, and recalibrates depth as the reader's real level shows itself. Checks can be answered as freeform text (the default, better for retention) or as quick 3-4 option multiple choice, switchable at any point. Requires a goal argument: what the reader should understand and still remember when it ends.
when_to_use: The user asks to be walked through, taught, or onboarded to a topic interactively, asks for a step-by-step/guided explanation, or invokes `/walkthrough <goal>`.
---

# Interactive walkthrough

This is the explicit, packaged form of the "one step at a time" mode CLAUDE.md's `Complex topics: lay it all out` section allows as an opt-in — here it's the default for the whole session, not a one-off request. CLAUDE.md's `Teaching`, `Tone`, `Repeat yourself, on purpose`, `Decode the names`, and the precision-over-abstraction bullet at the top of `Rules` all still apply — but through the core rule below: none of them adds to a step anything its questions do not need. Where one would, the material moves instead:

- `Teaching`'s naive attempts become steps of their own, each with a question about exactly where it breaks.
- `Teaching`'s general principle, its parallels from outside the project, and the durable takeaway go to the ending (§8), or into a step whose question asks the reader to spot the same shape.
- `Repeat yourself, on purpose` happens across steps, as restated ingredients — never as several phrasings inside one step.
- `Context means the trace` belongs to the interactions and code levels (top down), and only the hops the goal's questions need.
- `Decode the names`: a name is decoded in the step it first enters, in a few words.
- `Tone` lives in the phrasing, never in an added sentence.

## The core rule: the bare minimum per step, and the questions decide what that is

**Every step carries the bare minimum of information** — not a short summary of a bigger explanation, but the smallest body from which the step's questions can be answered. This is the goal the rest of the skill exists to reach: nearly every rule below either removes something from a step or moves it into a step of its own. When any rule, here or in CLAUDE.md, would add to a step, this one wins.

What counts as the minimum is decided by the questions, through two conditions:

1. **The questions cover the goal.** Someone who read no step body at all, but answered every question correctly, knows everything the goal (§1) requires. And every question is needed by the goal: one testing something the goal does not require is cut, with its step.
2. **Each step is exactly what its questions need.**
   - **Not less.** For each question, point to the sentences the answer is built from. If an ingredient was introduced in an earlier step, restate it here — the reader never scrolls back to answer. These restatements are where `Repeat yourself, on purpose` happens in a walkthrough: across steps, each time an earlier fact becomes an ingredient again.
   - **Not more.** For each sentence, name the question that needs it. A sentence no question needs is cut, or moved to a step whose question does — however true, relevant, or interesting it is.
   - **Not the answer itself.** The body holds the ingredients; the question asks how they connect (§3). A sentence that can be copied out as the answer turns the check into a search.
   - **Without confusion.** Every ingredient is stated precisely, and nothing in the body competes with it for attention.

Plan in this order: goal → the pieces of knowledge it requires → one narrow question per piece → the body that answers exactly those questions. Before chunk 1, check condition 1 against the list of questions alone: if every one were answered correctly, could the reader explain the goal? Whatever they could not is a missing question.

What follows from this:

- How the pieces connect is part of the goal, so it gets questions too: later steps ask questions joining earlier ones, and the last question is the goal itself, put to the reader (§8).
- Skipping content never skips a question. When §6 finds the reader ahead, a step's questions are asked without its body; only a correct answer lets the body go.
- A question the reader explicitly skips (§3) is a hole in the goal; the ending (§8) names it as not reached.
- An answer counts toward the goal only once it passes §3's guess-versus-grasp probe.

## Top down: the concept before any code

The walkthrough descends one level at a time and never starts below the top. The default ladder:

1. **Problem** — what goes wrong, for whom, and why it cannot simply be removed.
2. **Concept** — the general mechanism, defined precisely (§2, new concepts), illustrated with a real-world example that contains no code.
3. **Interactions** — how the parts of the system talk and store: which services, which network requests and API endpoints (method, path, the fields that matter), which database reads and writes (which table and columns, read or write, in what order). Words and ASCII diagrams only. A request's shape is a wire format, not code; "replica A reads `owner` of row 7 in `jobs`, then writes it" is an interaction; the SQL statement that does it is code.
4. **Code** — the implementation: statements, functions, `file:line`.

Other levels go in between when the goal needs them — a library's own model between concept and interactions, say. The order is fixed: nothing from a lower level appears before the level above it is done.

- **No code until the concept is learned.** A concept is never explained through a code example. Its concrete example at level 2 comes from outside software — the last seat on a flight, two cashiers and one till — with real values all the same.
- **Descend only when the level above is solid:** every question at that level has passed (§3). A skipped one is offered again before descending.
- **The goal sets how deep to go.** A goal whose questions are all answerable at level 2 never reaches code; lower levels exist only when the goal's questions require them (core rule).
- **Top down across the whole walkthrough**, not per concept: every concept the goal needs at the upper levels first, then the lower ones. The agenda (§1) is grouped by level.
- Precision at levels 1-2 means the definition and its conditions; naming rows, columns and request fields (§2) applies from level 3 down. Concreteness applies at every level: the real-world example carries specific values.
- A question stays at its step's level: a level-2 question contains no code, and no table or endpoint names either.

## 0. Per-user settings — read this first

Every reader tunes a walkthrough differently: one wants 30-second steps, another is fine with three-minute ones. Those preferences live in a local JSON file, **per user, not per project**:

```
~/.claude/walkthrough.json
```

It sits outside this skill's own directory deliberately. The skill directory is version-controlled and shared between machines and people; a personal preference written in there would be committed and imposed on everyone else who installs the skill.

**At the start of every walkthrough:** read that file. If it does not exist, create it with the defaults below and say in one line that it was created and where, so the reader knows there is something to tune. Never block the start on it — the defaults below are authoritative on their own, and the file only overrides them.

```json
{
  "chunk_read_minutes": [0.4, 0.6],
  "questions_per_chunk": [1, 2],
  "answer_mode": "ask",
  "gate_on_answers": true,
  "recap_every_response": true,
  "glyphs": true,
  "diagrams": "ascii",
  "language": "en",
  "starting_level": "zero-context",
  "repeat_complex_times": [3, 5]
}
```

| Key | Governs | Notes |
|---|---|---|
| `chunk_read_minutes` | §2 chunk length | default ≈30 seconds, roughly 60-90 words (1 minute ≈ 150 words of technical prose). Measures the chunk body, including any takeaway line; not the status block or the questions. Changing it re-divides the content into more or fewer steps, never trims it (§2) |
| `questions_per_chunk` | §3 how many checks | lower bound 0 disables checks for a reader who only wants the material |
| `answer_mode` | §3 how checks are answered | `ask` asks once at the start; `freeform` or `test` skips that question for a reader who already knows which they want |
| `gate_on_answers` | §3 the gate | `false` delivers chunks back to back without waiting; the questions still get asked |
| `recap_every_response` | §5 status block | `false` shows it only when the step changes |
| `glyphs` | §5 glyph vocabulary | `false` for a terminal that renders emoji badly — fall back to `[x]`, `[ ]`, `>>` |
| `diagrams` | §2 visuals | `ascii`, or `obsidian` for a reader who would rather have real diagrams and follow links |
| `language` | the walkthrough's prose | code identifiers, paths and error strings stay verbatim regardless |
| `starting_level` | §1 opening assumption | `zero-context` or `experienced`; §6 recalibrates from there either way |
| `repeat_complex_times` | §2 re-explanation budget | how many times a genuinely complex point is restated before it is assumed landed |

An unknown key is left alone rather than deleted — a newer version of this skill may own it. A malformed file is reported in one line and the defaults are used; never fail a walkthrough over its config.

### If a knowledge-map skill is installed

Optional, and the walkthrough works identically without it. There is no declared dependency between skills — a standalone `SKILL.md` has no `dependencies` field — so the link is just this: check whether a `knowledge-map` skill is listed, and if it is, invoke it and use what it knows.

- **At the start**, read the relevant subject or project file and take the opening depth from the recorded band rather than defaulting to zero context (§1). A topic already scored 75 does not get taught from scratch.
- **At the end, or at a natural pause**, hand back what the checks revealed: each graded question, the answer, and whether the reasoning held. That is exactly the evidence the map scores on, and a walkthrough generates more of it than anything else. Batch it — one write, not one per question.
- If no such skill is listed, skip all of this silently. Never mention a missing skill to the reader, and never ask them to install one.

## 1. Opening message

**The goal is a required argument.** A walkthrough is defined by what the reader should be able to explain, and still remember, when it ends — not by which topic gets covered. If the invocation carried no goal (`/walkthrough` with nothing after it, or a bare topic name like "langgraph"), ask for it and start nothing until it's answered: what should the reader walk away knowing? Inventing a goal from a bare topic is a guess, and every later decision is derived from it — which steps exist, what each chunk covers, which questions gate it, and what the ending checks.

**Settle the answer mode before chunk 1**, resolving in this order: stated in the goal message → use it silently; set to `freeform` or `test` in `~/.claude/walkthrough.json` → use it silently; otherwise ask, in one short question, with the trade-off of each named (§3). Freeform wins if the reader doesn't pick.

Then, before any teaching content:

1. **The goal, restated.** One or two lines in your own words, so the reader can correct the target before any effort is spent aiming at the wrong one.
2. **The problem, in one or two lines** — enough to show why the walkthrough exists. The problem itself (what goes wrong, why it can't simply be removed, why the naive fix fails) is taught by the steps of the first level (top down), with questions like any other step.
3. **The full agenda.** List every planned step, one line each, each named for what it contributes to the goal, grouped under the levels it belongs to (top down, above), so the shape of the whole walkthrough is visible before starting — same reasoning as `Complex topics: lay it all out`'s "say up front how many parts there are," delivered as a table of contents instead of inline steps.
4. Immediately follow with chunk 1 in the same message — don't stop to ask permission to begin.

Take the opening depth from the knowledge map's band for this topic when one exists (§0). Otherwise start from `starting_level`, which defaults to **zero context and junior-or-below technical competence**, regardless of how the reader has come across earlier in the session — a specific topic can be one they've never touched even if others weren't. Don't ask "what's your level?" up front; §6 is the actual instrument for measuring it.

## 2. Each chunk

- **Length:** set by `chunk_read_minutes` (§0) — about 30 seconds by default. Length decides how the material is divided into steps, never how much of it there is or how precise it is: smaller chunks mean more steps, larger chunks mean fewer. Never meet a length by dropping a definition, a condition, an example mapping, or a check — those are exactly what shortening cuts first. Level (§6) is the only thing that may remove content, and even it never removes a question (core rule).
  - Cut at the seam between notions, so every step keeps one crucial point of its own for its questions to aim at (§3). A step left without one was cut in the wrong place.
  - When steps merge, the merged step keeps a check for every crucial point it absorbed, even past `questions_per_chunk`.
  - A resize requested mid-walkthrough re-divides the remaining steps and is announced as an agenda change (§7); the step count in the status block changes with it.
- **No Mermaid in plain chat.** Claude Code's terminal doesn't render Mermaid — assume that's the medium unless the walkthrough is explicitly landing in something that renders it (an Obsidian note, a claude.ai Artifact). Use an ASCII diagram instead when a diagram earns its place.
- From the interactions level down (top down), every sentence describing a mechanism must be precise, never abstract: name the actual database row/column, network request/response field, or code-level construct involved — never a metaphor or an anthropomorphized stand-in for the literal fact (`Rules`, top bullet). Short is not an exemption from this.
- Never mention an entity ("the user", "the run", "the ticket") without saying which representation of it is meant — the row and which columns, the in-code object and which fields, or the identifier used as a foreign key elsewhere. This is the bare entity reference `Rules` bans, and a walkthrough introducing a new entity is exactly where it's most tempting to skip.
- Give every entity its address too — which database and table, which service, which repo or file — and restate that address in each later step whose questions need the entity, not only the first. A walkthrough is where an entity is met for the very first time, so the address has to land here or it never will.
- Every chunk still gets a concrete, real-valued example — an abstract statement of the rule alone never counts as the explanation. It is the walkthrough's **running example**, the same one across steps (one flight and seat 12A at the concept level; one job and two replicas further down), so no step spends words setting up a new one.
- When the goal includes a decision that was already made — in a ticket, in merged code, in a review — whether it was the right call gets its own step and question, not a paragraph appended to the step explaining what it was. Presenting a past decision as self-evidently correct teaches the reader to recite it; `Doubt the proposal` applies to explaining work just as much as to doing it, and being able to say what was wrong with a design is most of being able to defend it.
- When a chunk covers something that changed, or something that should change, show both states side by side — было/стало, or "сейчас / как должно быть" — with everything but the difference held identical. In plain chat that's two short blocks, not a diagram (§2's Mermaid rule still applies).
- The reader is not a native English speaker. Any idiom or colourful word gets glossed on the spot, together with whether it's a term of art with a precise meaning or just figurative English — that ambiguity is what actually trips them up, not the word itself. Keep using such words; a walkthrough is a good place to pick them up, as long as each one is explained.
- Assume zero context for each new concept the first time it appears, regardless of how technical the reader has seemed on other topics. Once introduced, anything genuinely complex or non-self-evident gets restated, in different phrasing, `repeat_complex_times` (§0) across the walkthrough before assuming it's actually landed — each restatement as an ingredient of a later step's questions (core rule), never as several phrasings inside one step. An already-obvious fact still gets one sentence; this is for what's actually hard, not everything. The categories `Repeat yourself, on purpose` marks as automatically complex — non-trivial SQL, transactions, and anything async/concurrent/parallel — always qualify here, no judgement call.
- **End every chunk with its check questions** — `questions_per_chunk` (§0), see §3.

### Introducing a new concept

The first statement of every new concept is a definition precise enough to be read only one way — the standard a definition in a textbook, a spec, or a statute has to meet. In order:

1. **The definition**: what kind of thing it is, then the property that sets it apart from everything else of that kind. Every word in it is already known or defined first.
2. **Its conditions**, as a numbered list — what must hold for something to count. Each one necessary, together sufficient. If a borderline case would be misclassified, a condition is missing or wrong.
3. **The mapping**: each term of the definition paired with the concrete thing it refers to in the step's example — the real-world example at the concept level, rows, requests and statements only from the interactions level down (top down, above).

Precise is not the same as dense: plain words stay plain (`Tone`). The test is whether a second reading is possible, not whether the sentence sounds formal. At the default step size, the definition with its conditions and the mapping are usually two steps, not one.

### Structure

A chunk is read in a terminal, often cold, often questions-first (§3). Its structure has to be visible before a word of it is read:

- **One notion per paragraph.** A paragraph introducing two notions hides the second.
- **Several of anything is a list, one item per line** — options, cases, steps, failure modes; never a comma-chain inside a sentence. Numbered by default, so each item can be referred to ("option 2"); bullets only for a short list whose items have no identity of their own. Say how many items there are, and why that many, before the list.
- **The crucial notion is bold where it is first introduced**, and defined in that same sentence. One or two per chunk at most: when everything is bold, nothing is. Unrendered, `**x**` still reads as emphasis, so this survives the terminal (§5).
- Code, queries and sequences of statements past a few tokens get their own indented block, not a place inside a sentence.

### When a chunk runs long

Splitting is the first fix (length, above). When a chunk still runs past the upper bound of `chunk_read_minutes` — one idea that does not split, a branch (§4), a re-explanation (🔁) — end the body, right before the questions, with:

```
If nothing else: <the one or two facts that carry the step>
```

It is for the reader who got lost partway: what they must hold to follow the next step even if the rest did not land. Questions are read first (§3), so the takeaway is seen first too — it states the conclusion, and the questions ask for the reasoning behind it. If the takeaway already answers a question, rewrite the question.

## 3. Comprehension check

What these questions are for: confirming the reader understands the problem this chunk covers, from more than one angle, and understands why the proposed solution was built the way it was — not confirming they can recall what the chunk just said. They are not memory-recall quizzes, not gotcha or trick questions, and not hypothetical-imagination exercises ("what if X changed instead"). A good question is one that narrows the reader — and the walkthrough — down to the one or two points in the chunk that actually matter, and confirms specifically those landed.

- Ask `questions_per_chunk` (§0) such questions per chunk, aimed at the problem and the reasoning behind the solution, never at wording recall or trivia.
- **Design test: a correct answer should be possible only two ways — the reader read and understood this chunk, or they already knew the material.** If a question can be answered by skimming, by general programming knowledge, by common sense, or by guessing from how the question itself is worded, it is testing nothing — rewrite it. And when a reader does answer correctly without having read the chunk, that isn't the check failing; it's the signal §6 acts on, that the level was pitched too low for them.
- **One reliable question type: ask for a restatement in the reader's own words** — the mechanism, or the sequence of what happens in what order, named in the question itself rather than pointed at (questions read first, below). This is not the recall quiz banned above, and the difference is the entire point: echoing the chunk's wording back takes no understanding, while re-expressing the same thing in different words cannot be done without it. If the answer can only come out in the chunk's original phrasing, that is itself the signal it hasn't landed. Keep it short — a sentence or two, or the steps in order. It is a quick grasp check, not a writing exercise.
- **Cover each crucial point, not the gist.** Reading a chunk, following 90% of it, and missing the one part that actually carries the weight is the common failure — and a question aimed at the overall shape of the chunk waves that reader straight through. Aim each question at a specific load-bearing point, and aim it where someone who skimmed *that particular part* would go wrong: the exact column, the exact ordering, the exact failure mode — not the headline the chunk was about.
- That design test does not conflict with the refresher §5 attaches to every restated question. The refresher repeats the *setup* — which entity, which field, which mechanism is in play — so the reader isn't hunting for context they already read once. The question asks for the *connection between those facts*, which no two-line refresher can hand over. Facts can be restated; understanding can't.
- Wait for an answer before moving on. Don't advance the walkthrough in the same message as the questions.
- Grade generously on wording, strictly on substance — and substance means the reasoning, not just the conclusion. A right-sounding answer can still be a guess; a guess and real understanding produce the same words. If the first answer states the conclusion without the reasoning behind it, ask one quick follow-up ("why") before deciding pass or fail — that follow-up is what tells a guess from a grasp, and it's a single quick check, not the re-explanation round below.
- A broadly-right answer that is silent on, or wrong about, the crucial part is a miss, not a pass. "Generous on wording" never means filling the missing piece in on the reader's behalf because everything around it sounded right — probe exactly the part they skipped. When that confirms the gap, the re-explanation (🔁) targets only the missing piece, not the whole chunk: someone who had 90% doesn't need the 90% again, and re-teaching it reads as not having listened to their answer.
- Only advance once the reasoning holds up, not just the stated conclusion. Treat missing, evasive, or contradicted reasoning the same as a wrong answer: re-explain the point from a different angle (`Repeat yourself, on purpose` — a different angle, not the same sentence again), then re-ask, before moving on.
- Don't turn this into an exam. One full clarifying round (re-explain + re-ask) per genuine miss is normal; if it's still not landing after that, the chunk itself was pitched wrong — rewrite it, don't keep re-testing the same explanation.

### The questions are read before the chunk

Questions sit at the end of a chunk, but a reader usually reads them first and then reads the body looking for their answers. Each question is therefore the reader's guide to what in the chunk matters. Write it for that use:

- **Two outcomes, and only two.** Read cold, a question either gets answered on the spot — the reader already holds the chunk's crucial point, and passes the step without reading the body — or it sends them into the body, to exactly the part that carries the weight, which contains its ingredients (core rule). A question that does neither is decoration and does not ship. The on-the-spot outcome means something only if the design test above holds: a question answerable by general knowledge or guessing proves nothing either way.
- **Aim at the point the chunk exists for.** Whatever a question targets is what gets read carefully; the rest gets skimmed. A question about a side detail steers attention onto that detail and away from the point.
- **Every question stands alone.** A reader who already knows the material answers it from the question's own text, without opening the body. So the question states its whole situation — at its level (top down): the real-world scene at the concept level; the services, requests, tables and values at the interactions level; the code at the code level — and never points into the body: no "this", "that", "the fix", "the naive version", "the second statement", "step 3", "condition 2". A reference is allowed only when its referent is inside the question itself. Established terms of art are fine; labels the walkthrough coined — a numbering, a handle from `Tone`, a nickname for a version of the code — are not, unless the question restates what they mean.
- **The question gives the situation; the body teaches the mechanism.** Stating the situation in full is not stating the answer: the answer is how the mechanism plays out in that situation, and that connection is what the reader supplies.
- One step's questions may share a **`Setup:`** stem printed directly above them — the exam convention of "questions 1-3 refer to the following code". The stem is part of the questions, not the body, and obeys the same rule.
- **The test:** cover the body and read the question alone. If someone who knows the topic could not answer it as written, it points into the body somewhere — find the reference and replace it with what it refers to.
- In test mode, the options obey the same rule.

### Answer mode: freeform or test

Checks come in two shapes, and the reader picks (§1). **Freeform is the default** — producing an answer from nothing forces retrieval and articulation, which is what actually builds retention, and it exposes gaps the reader didn't know they had. Multiple choice is faster and lower-friction, which genuinely matters on dense material or late in a long session, and its wrong options can teach by showing the plausible-but-mistaken readings side by side. State that trade-off in one line whenever the choice comes up, so it's an informed pick rather than a coin flip.

**The reader can switch at any point**, just by saying so. Honour it from the next question onward; never re-ask what has already been answered in the other mode.

**Write the question for the mode — they are not the same question in two costumes.**

- Freeform keeps everything above: reconstruct the mechanism, say why, restate the sequence in your own words.
- Test mode cannot ask for a restatement, and recognition is far easier than recall — so a lazily-converted freeform question becomes much weaker as multiple choice. Compensate deliberately:
  - **Every wrong option is a specific, real misunderstanding**, not filler. Done properly, *which* wrong answer gets picked tells you what the reader actually misunderstands — that diagnostic is the one thing test mode does better than freeform, and it's lost entirely if the distractors are throwaway.
  - **No option is eliminable without understanding.** No "all of the above", nothing absurd, and never make the correct answer the longest or most hedged one — those are patterns a reader learns to game instead of learning the material.
  - **Ask for the reason, not the label**: "which of these is *why* the second replica kills the run" beats "what does `owner` store".
  - **A correct pick is weaker evidence than a correct freeform answer** — one in four lands by luck. So §3's guess-versus-grasp probe matters *more* here, not less: after a correct pick on anything load-bearing, ask for a one-line why before counting it.

**The questions are a gate, not a suggestion — once asked, they stay open regardless of what happens next in the conversation.** If the reader goes on a tangent, asks something unrelated, or asks about something else entirely, that does not clear the open questions: answer what they actually asked, then return to the still-open questions before advancing. Never let the walkthrough drift into the next chunk just because the conversation moved elsewhere. The only way past an open question, besides answering it, is the reader explicitly or clearly-implicitly asking to skip it ("skip this", "let's just move on") — absent that, there is no other path forward.

## 4. Branching on a clarifying question

A clarifying question mid-walkthrough is not an interruption to be answered and waved away. It is **one more thing the reader needs to understand**, so it gets taught properly, like any other step. Getting this right is most of what makes a walkthrough worth doing at all.

- **Teach the branch, don't just answer it.** It follows every rule a normal chunk follows — the length from `chunk_read_minutes` (§0), precision, a real example, ASCII over Mermaid (§2) — and it gets its own check questions per §3. A branch delivered as a loose aside with no check teaches nothing and quietly leaves the gate open.
- **The branch inherits the reader's settings; it does not get its own.** At the default `chunk_read_minutes` of about 30 seconds, the branch is a 30-second read too. Being a tangent is not a licence to run long.
- **The suspended question survives.** Opening a branch puts the main step's last asked-but-unanswered question on hold. When the branch's own checks pass — or are explicitly skipped — return to exactly that question and re-ask it, restated with the facts needed to answer it per §5, because the reader has been somewhere else in between.
- **Branches nest, and unwind innermost first.** A clarifying question asked inside a branch opens another level. Resolve the deepest one, then its parent, then the main line. The status block (§5) carries the whole stack, so the reader can always see how deep they are and what is still waiting above them.

### When the branch would go too deep

Sometimes a proper answer needs a dive that pulls the walkthrough well off its goal. Don't quietly take that detour, and don't quietly refuse it — **say so, then let the reader choose**:

1. Name what a full answer actually requires, and how far off-goal it goes, concretely: "answering this properly needs transaction isolation levels first, which is three or four steps of its own."
2. Put the options up: **take the full branch now**; **drop it for now**; **a high-level answer only**, enough to carry on toward the goal; or **split it into its own walkthrough for later**.
3. Offer a fifth option when the situation suggests one — those four are the common cases, not a closed list.
4. If the reader doesn't choose, the high-level answer is the default: it unblocks the goal without silently committing them to a long detour.

A dropped branch and a deferred separate walkthrough are both things the reader will want to find again. Record either in the agenda per §7, so the decision is visible rather than lost in scrollback.

## 5. Status recap and visual markers

Every response while a walkthrough is running — not only the ones delivering a new chunk — opens with a short status block, so the reader never has to scroll up to work out where they are — a walkthrough can sit open for hours while they're pulled onto other work, and this block is what lets them resume cold — and so a walkthrough response is distinguishable from ordinary chat at a glance:

````
🎓 Walkthrough · Step 2 of 5 — <step name> · answered 1/3
🎯 Goal: <goal, one short line>
↳ Branch: <the clarifying question being taught>  ·  waiting above: step 2 Q2

──────────────────────────────────────────────

✅ Q1 — <the question, one line>

  You said: <the reader's answer, in their own words>

  Verdict: <what that answer established, or what it missed — its own line>

──────────────────────────────────────────────

❓ Q2 — <the question, one line>   [open]

  Facts needed to answer it:
    · <one fact per line, never a comma-chain inside the question>
    · <one fact per line>
````

**One kind of information per block — this is what breaks first.** A single line carrying the question, the reader's answer, your verdict on it, and the supporting facts is unreadable even when every word is correct: there is no seam to find. So:

- The question sits **alone on its own line**, prefixed `Q<n> —`, so it can be found without reading around it.
- The reader's own answer carries an explicit **`You said:`** label. That label, not a blockquote, is what separates *their words* from *your comment on their words* — see the plain-text rule below for why.
- Your verdict gets its **own line**, never appended to the answer.
- Facts needed are a **list, one per line** — never folded into the question's sentence.
- A horizontal rule of `─` between questions, blank lines within each.

**Do not lean on Markdown to carry any of this.** The reader usually runs walkthroughs in a terminal, so assume the raw characters are what they see: structure has to survive unrendered. That means explicit word labels (`You said:`, `Verdict:`, `Facts needed:`) rather than `**bold**` or `>` doing the work; indentation and blank lines rather than nesting syntax; `─` runs rather than `---`; and never a Markdown table, which wraps into mush at terminal width. Emphasis markers are fine as a bonus when they do render — they must never be the only thing marking a boundary.

**Anything visual is ASCII by default.** Box-drawing characters, arrows, indented trees, aligned columns padded with spaces — these look right in a terminal and cost nothing. Mermaid never renders there, so it is not an option in chat.

**The Obsidian escape hatch is an exception, not the routine.** When a diagram genuinely cannot be done in ASCII — a real graph, a layered schema, something with crossing edges — write it into a vault note per `Obsidian` and give the link. Reaching for that on every step defeats the point of an interactive walkthrough: the reader is in the terminal, and sending them to a file breaks the flow. Ask whether ASCII can carry it first; it usually can.

- Include it even when the response is answering a side question, clarifying a term, or handling a tangent — not only when the walkthrough itself advances.
- A clarifying question about the current chunk means the reader stopped reading at that point — the rest of that chunk is probably still unread. Answer it, then hand them back to the exact spot they stopped at. A clarification never counts as having cleared the chunk, and never advances the walkthrough to the next step.
- Never answer anything blindly: name which question this response is addressing — the reader's side question, or which of the open check questions their answer landed on — re-posed in cleaner words than it was asked in, before answering it. The block shows what's *open*; this shows what's being *dealt with right now*. A reader who has been away, or who fired off three things at once, must never have to work out which one just got answered.
- **Every restatement of an open question carries the information needed to answer it** — its `Setup:` stem (§3) if it has one, the relevant mechanism, the entity and field names in play, the setup the question is about — so the reader can answer from the block alone without scrolling back to the chunk. Not the answer itself, and not the chunk re-pasted: the general facts that lead to the answer, one or two lines. Repeating the conclusion the question is testing makes the check worthless; repeating nothing makes the reader hunt for context they already paid attention for once.
- An answered question's line is not just a checkmark: restate in one line what the reader's answer actually established. That does double duty as the repeated confirmation `Repeat yourself, on purpose` already asks for, rather than costing anything extra.
- **While a branch (§4) is open, the block shows the stack**: one `↳` line per level, innermost last, each naming what is being taught and what question is waiting above it. Drop the `↳` lines as each level resolves. Without this the reader cannot tell a branch from the main line, and "where was I?" becomes unanswerable without scrolling — the exact failure this block exists to prevent.
- When a step's questions are all answered or explicitly skipped (§3) and the next chunk starts, the block resets to that chunk's own questions — a resolved step's questions don't get carried forward.
- This is exactly why chunks in §2 stay small: the block repeats on every message for as long as a step's questions are open, so a bigger step means paying for its recap more times and for longer. Small steps keep the recap a small fraction of each response instead of the bulk of it.

These glyphs carry fixed meanings and are used consistently for the whole walkthrough:

| Glyph | Means |
|---|---|
| 🎓 | walkthrough mode is active — opens the status block |
| 🎯 | the goal (§1) |
| ✅ | question answered and accepted |
| ❓ | question still open |
| ↳ | an open branch from a clarifying question (§4) — one line per nesting level |
| 🔁 | re-explaining after a missed check (§3) |
| ⚠️ | agenda or pacing change (§6, §7) |
| 🏁 | walkthrough complete (§8) |

- They are status signals, not decoration. The teaching prose in each chunk stays plain, precise text per §2 — a walkthrough that sprinkles emoji through its explanations is worse than one with none.
- Keep the set fixed. Inventing a new glyph mid-walkthrough defeats the point: the reader learns them once and can then parse any response without reading it closely.
- This is scoped to walkthrough mode. Outside it, the normal no-emoji default applies.

## 6. Recalibrating the level as you go

- Read each answer for more than correct/wrong: precise unprompted vocabulary, a caught edge case, a question that skips ahead — all of that means the assumed level was too low. A vague or only-partially-right answer that just echoes the words just given back means the level is about right, or still too high.
- Adjust what comes next, never the set of questions (core rule). Reader ahead of the material: deliver the next step's questions without its body, and send the body only if an answer misses. Reader struggling: add a step that teaches the missing ingredient, with its own question, rather than lengthening the current one.
- Say so once, briefly, the first time a real shift happens ("you clearly already know X, so I'll skip re-deriving Y and move faster from here") — the same no-silent-deviation principle as §7, applied to pacing instead of content. Don't narrate a running commentary on every question's grade.

## 7. Changing the agenda mid-walkthrough

Finding out partway through that a step is missing, needs splitting, or needs reordering is normal, not a failure — the agenda from §1 is a plan, not a contract. When it happens: say so explicitly before delivering the changed content ("this needs one more step than planned, because X"), update the visible agenda, then continue. Never insert or reorder a step silently — that's the mental-model-reversal `Rules` already bans, applied here to the walkthrough's own shape.

## 8. Ending

The last question puts the goal itself to the reader (core rule). Once it passes, close by confirming what their answer established — what they can now explain that they couldn't at the start — and list every skipped question as a part of the goal not reached, rather than letting it pass silently. Then a short recap: the central problem from §1, the one or two central conclusions (`Teaching`'s rule on calling out the central problem(s) first), and the general principle this was an instance of. Write this recap as if it might get pasted somewhere and stand alone — that's the same bar `The opening paragraph is a triage test` sets for what a future revisit of this material should find.
