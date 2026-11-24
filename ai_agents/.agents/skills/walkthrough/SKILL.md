---
name: walkthrough
description: "Teach a stated learning goal in short, comprehension-gated steps. Start with a single 0–5 knowledge questionnaire to set the depth for each concept. Show the agenda before teaching, check understanding after each step, and adjust depth as the reader answers. Checks can be freeform or multiple choice. Requires a goal that states what the reader should be able to explain at the end."
---

## Codex compatibility

Use `$walkthrough` to invoke this skill. Resolve tools from those actually available in the current session; never assume Claude plugins or tools exist. Preserve user authorization boundaries.


# Interactive walkthrough

This is the explicit, packaged form of the "one step at a time" mode CLAUDE.md's `Complex topics: lay it all out` section allows as an opt-in — here it's the default for the whole session, not a one-off request. CLAUDE.md's `Teaching`, `Tone`, `Repeat yourself, on purpose`, `Decode the names`, and the precision-over-abstraction bullet at the top of `Rules` all still apply — but through the core rule below: none of them adds to a step anything its questions do not need. Where one would, the material moves instead:

- `Teaching`'s naive attempts become steps of their own, each with a question about exactly where it breaks.
- `Teaching`'s general principle, its parallels from outside the project, and the durable takeaway go to the ending (§8), or into a step whose question asks the reader to spot the same shape.
- `Repeat yourself, on purpose` happens across steps. Plan repeated practice for the facts the final goal depends on.
- `Context means the trace` belongs to the interactions and code levels (top down), and only the hops the goal's questions need.
- `Decode the names`: a name is decoded in the step it first enters, in a few words.
- `Tone` lives in the phrasing, never in an added sentence.

## The core rule: the bare minimum per step, and the questions decide what that is

**Every step carries the bare minimum of information** — not a short summary of a bigger explanation, but the smallest body from which the step's questions can be answered. This is the goal the rest of the skill exists to reach: nearly every rule below either removes something from a step or moves it into a step of its own. When any rule, here or in CLAUDE.md, would add to a step, this one wins.

**Assume the reader has forgotten most of the previous step when the next one starts.** Restate any earlier fact where the next step needs it. Identify the sequences, distinctions, and other facts the reader must retain to achieve the final goal. Plan **three to five additional restatements after the first explanation**, spread across later steps. For a sequence, restate the ordered actions. For a distinction, restate the exact meaning of each term. Vary how the reader uses the same example while keeping names and facts consistent.

Make each restatement serve a question or a short retention step. At a later step, ask the reader to reconstruct or apply the information without putting the conclusion in the question. A successful answer immediately after the first explanation establishes understanding at that point. Use a later answer to check retention, and keep revisiting the information if the reader still needs help.

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
~/.codex/walkthrough.json
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
| `repeat_complex_times` | §2 repetition for other complex material | number of restatements after the first explanation. For facts the final goal depends on, follow the core retention rule |

An unknown key is left alone rather than deleted — a newer version of this skill may own it. A malformed file is reported in one line and the defaults are used; never fail a walkthrough over its config.

An existing `starting_level` key is preserved on disk. The opening assessment in §1 determines the starting depth.

### If a knowledge-map skill is installed

Optional, and the walkthrough works identically without it. There is no declared dependency between skills — a standalone `SKILL.md` has no `dependencies` field — so the link is just this: check whether a `knowledge-map` skill is listed, and if it is, invoke it and use what it knows.

- **At the start**, read the relevant subject or project file to identify concepts worth including in the questionnaire. Use the reader’s current ratings to set the starting depth (§1).
- **At the end, or at a natural pause**, hand back what the checks revealed: each graded question, the answer, and whether the reasoning held. That is exactly the evidence the map scores on, and a walkthrough generates more of it than anything else. Batch it — one write, not one per question.
- If no such skill is listed, skip all of this silently. Never mention a missing skill to the reader, and never ask them to install one.

## 1. Opening assessment and first chunk

**The goal is a required argument.** A walkthrough is defined by what the reader should be able to explain, and still remember, when it ends — not by which topic gets covered. If the invocation carried no goal (`/walkthrough` with nothing after it, or a bare topic name like "langgraph"), ask for it and start nothing until it's answered: what should the reader walk away knowing? Inventing a goal from a bare topic is a guess, and every later decision is derived from it — which steps exist, what each chunk covers, which questions gate it, and what the ending checks.

**Assume zero prior context and junior-level experience.** Once the goal is known, restate it briefly and ask one questionnaire before teaching. Use the ratings to decide how much time and detail each concept needs.

- Ask about **5–10 concepts**, up to **15** if the goal or system is complex. Ask about one concept per item. Cover the prerequisites the goal actually needs, from general computer science, AI agents, or web concepts to business rules and specific parts of the system. Use plain language so the reader can recognize each concept.
- Use the same **0–5 scale** for every concept. **0** means “I know nothing about this.” **1** means “I recognize the term.” **2** means “I can follow an explanation with help.” **3** means “I can explain the basics on my own.” **4** means “I can apply it in common cases.” **5** means “I need no clarification.”
- Present all items together. Use one interactive form if the harness can collect a 0–5 rating for every item in one submission. Otherwise show a numbered list and ask for a series of numbers in order, for example `0, 4, 2, 5, 1`.
- Wait for the ratings or an explicit request to skip the questionnaire. Use the junior, zero-context baseline for any unrated concept. For ratings of 0–1, teach from first principles. For 2–3, define the essentials and connect them to the goal. For 4–5, start with a short check or the part specific to the system. The ratings guide depth. The comprehension checks in §3 establish understanding.

**Turn important knowledge gaps into subgoals before writing the agenda.** A subgoal states what the reader must be able to explain or do to achieve the final goal. Add a subgoal when the ratings indicate a knowledge gap, a later step or question depends on that knowledge, and the gap needs separate teaching. For a gap that a brief definition can close, give the definition in the step that uses it. Name each subgoal in the agenda and give it one or more short steps with a comprehension check. Place those steps before the first step that depends on the subgoal, keeping the walkthrough’s top-down order.

For example, if the final goal is to explain why retrying a payment request can charge a customer twice, and the reader rates client timeouts at 1, add a subgoal to explain what the client can infer about the payment server’s state after a timeout. Check that subgoal before teaching the duplicate-charge mechanism.

**Settle the answer mode before chunk 1.** Use the mode stated in the goal message or set to `freeform` or `test` in `~/.codex/walkthrough.json`, in that order. Otherwise add one optional answer-mode choice to the questionnaire using the trade-off in §3. Use freeform if the reader leaves the choice blank.

In the first teaching response after the questionnaire:

1. **The goal, restated.** One or two lines in your own words, so the reader can correct the target before any effort is spent aiming at the wrong one.
2. **The original problem.** State what happens, who or what it affects, and what outcome is needed. Save the detailed causes and failure cases for the teaching steps.
3. **A bird’s-eye overview of the players.** Name every concept, system, service, and participant relevant to the goal. Give each a short description of its role in the original problem. Use the questionnaire ratings to define unfamiliar terms in plain language on first mention. Show how the players relate at a high level. Leave implementation details for the appropriate teaching level.
4. **Comparison tables.** Whenever understanding depends on distinguishing services or concepts, compare them in a table, both in the overview and when a new distinction comes up in a later step. Use the same comparison criteria for every item. Include only the differences that matter to the goal. Use aligned plain-text columns in a terminal and a Markdown table when the interface renders it.
5. **The full agenda.** List every planned step, one line each, grouped by teaching level. Name what each step contributes to the goal, including any subgoals.
6. Deliver chunk 1 immediately after the agenda in the same response.


## 2. Each chunk

- **Length:** set by `chunk_read_minutes` (§0) — about 30 seconds by default. Length decides how the material is divided into steps, never how much of it there is or how precise it is: smaller chunks mean more steps, larger chunks mean fewer. Never meet a length by dropping a definition, a condition, an example mapping, or a check — those are exactly what shortening cuts first. Level (§6) is the only thing that may remove content, and even it never removes a question (core rule).
  - Cut at the seam between notions, so every step keeps one crucial point of its own for its questions to aim at (§3). A step left without one was cut in the wrong place.
  - When steps merge, the merged step keeps a check for every crucial point it absorbed, even past `questions_per_chunk`.
  - A resize requested mid-walkthrough re-divides the remaining steps and is announced as an agenda change (§7); the step count in the status block changes with it.
- **No Mermaid in plain chat.** The Codex terminal doesn't render Mermaid — assume that's the medium unless the walkthrough is explicitly landing in something that renders it (an Obsidian note, a rendered document). Use an ASCII diagram instead when a diagram earns its place.
- Use a comparison table when a step requires the reader to distinguish services or concepts (§1).
- From the interactions level down (top down), every sentence describing a mechanism must be precise, never abstract: name the actual database row/column, network request/response field, or code-level construct involved — never a metaphor or an anthropomorphized stand-in for the literal fact (`Rules`, top bullet). Short is not an exemption from this.
- Never mention an entity ("the user", "the run", "the ticket") without saying which representation of it is meant — the row and which columns, the in-code object and which fields, or the identifier used as a foreign key elsewhere. This is the bare entity reference `Rules` bans, and a walkthrough introducing a new entity is exactly where it's most tempting to skip.
- Give every entity its address too — which database and table, which service, which repo or file — and restate that address in each later step whose questions need the entity, not only the first. A walkthrough is where an entity is met for the very first time, so the address has to land here or it never will.
- Every chunk still gets a concrete, real-valued example — an abstract statement of the rule alone never counts as the explanation. It is the walkthrough's **running example**, the same one across steps (one flight and seat 12A at the concept level; one job and two replicas further down), so no step spends words setting up a new one.
- **Use self-descriptive names for fictional entities in the running example.** Name the role, state, or difference the reader needs to notice. For a project lifecycle example, use `deleted-project` and `just-created-project`. Match the naming style to the medium and carry the same names through every step, diagram, and question. When a real name is needed, explain its role or state on first mention.
- When the goal includes a decision that was already made — in a ticket, in merged code, in a review — whether it was the right call gets its own step and question, not a paragraph appended to the step explaining what it was. Presenting a past decision as self-evidently correct teaches the reader to recite it; `Doubt the proposal` applies to explaining work just as much as to doing it, and being able to say what was wrong with a design is most of being able to defend it.
- When a chunk covers something that changed, or something that should change, show both states side by side — было/стало, or "сейчас / как должно быть" — with everything but the difference held identical. In plain chat that's two short blocks, not a diagram (§2's Mermaid rule still applies).
- The reader is not a native English speaker. Any idiom or colourful word gets glossed on the spot, together with whether it's a term of art with a precise meaning or just figurative English — that ambiguity is what actually trips them up, not the word itself. Keep using such words; a walkthrough is a good place to pick them up, as long as each one is explained.
- Set the depth for each new concept from its questionnaire rating (§1) and any comprehension checks on that concept (§6). Use the junior, zero-context baseline for unrated concepts. For facts the final goal depends on, apply the core retention rule. For other genuinely complex facts, use `repeat_complex_times` (§0) across steps. Non-trivial SQL, transactions, and asynchronous, concurrent, or parallel execution always qualify as complex.
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

Splitting is the first fix (length, above). When a chunk still runs past the upper bound of `chunk_read_minutes` — one idea that does not split, an active subgoal (§4), a re-explanation (🔁) — end the body, right before the questions, with:

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
- In check questions and answer options, use names that describe facts the question gives the reader. Leave the conclusion the reader must derive out of the names.
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

## 4. Adding a subgoal during a walkthrough

A reader’s clarifying question can reveal a topic that needs its own teaching. If a short clarification resolves the question, answer it and return the reader to the point where they stopped.

1. **Ask before adding a subgoal.** Name what the reader would be able to explain and ask, “Do you want to add this as a subgoal?” Wait for the reader’s approval before adding the subgoal to the agenda (§7). If the reader declines, give a short clarification if they want one and return to the paused point. For a topic that would take the walkthrough far from the final goal, say what the extra teaching would cover and offer to defer it to a separate walkthrough.
2. **Put the approved subgoal on top of the subgoal stack.** Record the exact point you’re pausing, including the current step and its open questions. Teach the approved subgoal first, using the same chunk settings and comprehension checks (§2–3). If the reader approves another subgoal while working through this one, put the newer subgoal on top and pause the current subgoal at its exact point.
3. **Resume the discussion that the completed subgoal interrupted.** When the active subgoal’s checks pass or the reader explicitly skips them, remove that subgoal from the top of the stack. Give a short refresher on the step or subgoal directly underneath and pick up where you paused. If a question was open, restate it with the facts needed to answer it (§5). The refresher is enough to continue from that point. The original check remains open until the reader answers or skips it.

## 5. Status recap and visual markers

Every response while a walkthrough is running — not only the ones delivering a new chunk — opens with a short status block, so the reader never has to scroll up to work out where they are — a walkthrough can sit open for hours while they're pulled onto other work, and this block is what lets them resume cold — and so a walkthrough response is distinguishable from ordinary chat at a glance:

````
🎓 Walkthrough · Step 2 of 5 — <step name> · answered 1/3
🎯 Goal: <goal, one short line>
↳ Subgoal: <what the reader should be able to explain>  ·  paused at: step 2 Q2

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

**Keep the status block readable as plain text.** Use explicit labels such as `You said:`, `Verdict:`, and `Facts needed:`, with indentation, blank lines, and `─` separators. Put comparison tables in the teaching content and format them for the interface (§1).

**Anything visual is ASCII by default.** Box-drawing characters, arrows, indented trees, aligned columns padded with spaces — these look right in a terminal and cost nothing. Mermaid never renders there, so it is not an option in chat.

**The Obsidian escape hatch is an exception, not the routine.** When a diagram genuinely cannot be done in ASCII — a real graph, a layered schema, something with crossing edges — write it into a vault note per `Obsidian` and give the link. Reaching for that on every step defeats the point of an interactive walkthrough: the reader is in the terminal, and sending them to a file breaks the flow. Ask whether ASCII can carry it first; it usually can.

- Include it even when the response is answering a side question, clarifying a term, or handling a tangent — not only when the walkthrough itself advances.
- For a clarifying question about the current chunk, answer it or ask whether to add a subgoal (§4). Preserve the reader’s place and all open checks when returning to the current chunk.
- Never answer anything blindly: name which question this response is addressing — the reader's side question, or which of the open check questions their answer landed on — re-posed in cleaner words than it was asked in, before answering it. The block shows what's *open*; this shows what's being *dealt with right now*. A reader who has been away, or who fired off three things at once, must never have to work out which one just got answered.
- **Every restatement of an open question carries the information needed to answer it** — its `Setup:` stem (§3) if it has one, the relevant mechanism, the entity and field names in play, the setup the question is about — so the reader can answer from the block alone without scrolling back to the chunk. Not the answer itself, and not the chunk re-pasted: the general facts that lead to the answer, one or two lines. Repeating the conclusion the question is testing makes the check worthless; repeating nothing makes the reader hunt for context they already paid attention for once.
- An answered question's line is not just a checkmark: restate in one line what the reader's answer actually established. That does double duty as the repeated confirmation `Repeat yourself, on purpose` already asks for, rather than costing anything extra.
- **Show the subgoal stack while a subgoal is active (§4).** Use one `↳` line per subgoal, with the newest active subgoal last. Each line names the subgoal and the point it paused. Remove the last line as each subgoal ends, then refresh the paused discussion.
- When a step's questions are all answered or explicitly skipped (§3) and the next chunk starts, the block resets to that chunk's own questions — a resolved step's questions don't get carried forward.
- This is exactly why chunks in §2 stay small: the block repeats on every message for as long as a step's questions are open, so a bigger step means paying for its recap more times and for longer. Small steps keep the recap a small fraction of each response instead of the bulk of it.

These glyphs carry fixed meanings and are used consistently for the whole walkthrough:

| Glyph | Means |
|---|---|
| 🎓 | walkthrough mode is active — opens the status block |
| 🎯 | the goal (§1) |
| ✅ | question answered and accepted |
| ❓ | question still open |
| ↳ | an approved subgoal and the point it paused (§4) |
| 🔁 | re-explaining after a missed check (§3) |
| ⚠️ | agenda or pacing change (§6, §7) |
| 🏁 | walkthrough complete (§8) |

- They are status signals, not decoration. The teaching prose in each chunk stays plain, precise text per §2 — a walkthrough that sprinkles emoji through its explanations is worse than one with none.
- Keep the set fixed. Inventing a new glyph mid-walkthrough defeats the point: the reader learns them once and can then parse any response without reading it closely.
- This is scoped to walkthrough mode. Outside it, the normal no-emoji default applies.

## 6. Recalibrating the level as you go

- Read each answer for more than correct/wrong: precise unprompted vocabulary, a caught edge case, a question that skips ahead — all of that means the assumed level was too low. A vague or only-partially-right answer that just echoes the words just given back means the level is about right, or still too high.
- Keep the existing comprehension checks (core rule). Reader ahead of the material: deliver the next step's questions without its body, and send the body only if an answer misses. If a check exposes a missing prerequisite, apply the subgoal rule in §1 and update the agenda under §7. Give the missing prerequisite its own short step and check when it needs separate teaching.
- Say so once, briefly, the first time a real shift happens ("you clearly already know X, so I'll skip re-deriving Y and move faster from here") — the same no-silent-deviation principle as §7, applied to pacing instead of content. Don't narrate a running commentary on every question's grade.

## 7. Changing the agenda mid-walkthrough

Finding out partway through that a step is missing, needs splitting, or needs reordering is normal, not a failure — the agenda from §1 is a plan, not a contract. When it happens: say so explicitly before delivering the changed content ("this needs one more step than planned, because X"), update the visible agenda, then continue. Never insert or reorder a step silently — that's the mental-model-reversal `Rules` already bans, applied here to the walkthrough's own shape.

## 8. Ending

The last question puts the goal itself to the reader (core rule). Once it passes, close by confirming what their answer established — what they can now explain that they couldn't at the start — and list every skipped question as a part of the goal not reached, rather than letting it pass silently. Then a short recap: the central problem from §1, the one or two central conclusions (`Teaching`'s rule on calling out the central problem(s) first), and the general principle this was an instance of. Write this recap as if it might get pasted somewhere and stand alone — that's the same bar `The opening paragraph is a triage test` sets for what a future revisit of this material should find.
