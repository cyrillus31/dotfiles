---
name: self-multiagent-review
description: Prepare a neutral fresh-agent prompt for repeated independent reviews of Cloud.ru GitLab MRs, cross-validate findings, and optionally fix confirmed defects with --fix. Use for multi-agent review handoffs, not ordinary single-pass code review.
---

# Self multiagent review

## Invocation and output

`$self-multiagent-review [--fix] <MR URLs or ticket> [context locations]`

Default: produce a copyable, self-contained prompt for a NEW agent. Do not
start reviewing or fixing the referenced work merely to prepare the prompt.
If explicitly asked to execute the review, follow the same protocol below.
`--fix` selects review-and-fix in the generated prompt; without it the review
is read-only except for local review artifacts and isolated test resources.
It does not authorize merging, deployment, or messages to other people.

Use the current request to resolve MR URLs, ticket, repositories, workspace,
documentation locations, and existing authorization. Inspect connected
sources or local metadata for missing addresses, not implementation history.
Ask only for essential inputs that cannot be resolved. Never substitute an
example ticket or silently expand the set of MRs.

Return a short table of mode, inputs, unresolved prerequisites, and destination,
followed by ONE copyable prompt block. The block must contain the concrete
context manifest and the executable protocol below, not merely a reference
to this skill. All reports produced by the prompt, including progress updates,
findings, validation, and final verdicts, must use Markdown tables. Instructions
and the copyable prompt itself need not be tables. Link large evidence artifacts
from table cells instead of placing unreadable logs in them.
Adapt other skills' prose/list report formats into tables while preserving their
review criteria and evidence; the user's table requirement governs presentation.

## Neutral context manifest

Provide addresses and source roles, not a summary of the author's reasoning.

| Source | Include in prompt | Access timing |
| --- | --- | --- |
| GitLab | MR URLs, repository locations; resolve actual source/target branches and SHAs at execution | Metadata and code first; verdicts and discussions later |
| Jira | Ticket URL, primary acceptance requirements and linked product requirements | First pass; separate requirements from suggested implementation |
| Workspace | Repo paths, applicable instruction files, test setup docs, artifact destination | First pass |
| System docs | Architecture, external contracts, operational constraints, with paths and scope | First pass after screening for implementation conclusions |
| History | Ticket folder, timeline, previous reviews, author replies, decision records | Withhold contents until independent reports are saved |
| Skills | Names and verified locations of available review and supporting skills | Read rules first; defer ticket-specific casebooks |

Discover skills in the active catalog, repository/workspace skills, and installed
agent skill directories. Include `$mr-review`, `$ponytail-review`, and
`$code-critic` when present, plus `$gitlab` for GitLab access. Resolve locations
instead of assuming these skills exist on every machine. Record missing skills
and capability gaps; never claim an unavailable skill was applied. Use relevant
language, debugging, security, validation, and ticket-log skills when applicable.

Do not put decisions, implementation rationale, previous findings, test totals,
readiness claims, suspected defects, or desired verdicts in the prompt. Names and
paths may themselves reveal context: record such exposure. Complete blindness
cannot be guaranteed when requirements and rationale share a document. Preserve
the exact authoritative requirement separately from its proposed solution;
do not remove requirements merely because they constrain the design.

## Protocol to include in the generated prompt

### 1. Establish evidence and boundaries

Determine whether the implementation satisfies the primary requirements.
Resolve current MR metadata through available GitLab tools, preferably the
available `$gitlab` skill and glab. Record head and target SHAs, actual target
branches, full MR diffs, and cross-repository contracts. Retrieve review history
into a separate location without distributing it to discovery reviewers.

Use immutable detached snapshots in isolated worktrees for review. Record a
snapshot manifest and file coverage; a moving branch name is not a snapshot.
If the ticket or primary requirements are unavailable, continue the feasible
code/contract review, list missing requirements, and mark product correctness
UNKNOWN. Do not invent acceptance criteria or claim full readiness.
Prepare isolated test dependencies. Never reset shared databases or overwrite
unrelated working changes. Missing access or dependencies must appear as limits.

The prompt requests fresh-context subagents and two independent discovery
rounds. Pass only neutral context, repository rules, and pinned snapshots to
each reviewer; use zero inherited conversation context where supported.
If this isolation or delegation is unavailable, report the limitation and
request independent sessions rather than calling repeated self-review independent.

### 2. Discover independently, twice

Run two full rounds against the SAME initial snapshots, with new agents in
each round. In each round obtain separate available mr-review, ponytail-review,
and code-critic assessments. Follow each skill's role constraints, including
static-only review where required; validators run experiments separately.
Queue reviewers when slots are limited. No reviewer sees another report before
saving its own initial report. Do not fix anything between these two rounds.

Cover the full changes, connected callers, relevant unchanged foundations,
product behavior, and cross-repository contracts. Partition large diffs explicitly
and record uncovered paths. Derive scenarios from requirements and code rather
than importing a prior review's checklist. Use other applicable skills without
letting ticket-specific historical conclusions bias discovery.

### 3. Cross-compare and verify

Save initial reports before consulting historical verdicts and discussions.
Merge duplicate findings by root cause, retaining reviewer and round provenance.
Assign another reviewer or validator to try to disprove each material finding.
Agreement is not proof; absence from another report is not refutation.

Use CONFIRM, PARTIAL, REFUTE, MOOT, or UNVERIFIED, backed by a reachable path,
concrete trigger, actual result, expected result, and code or runtime evidence.
Separate introduced defects, related pre-existing defects, and unrelated debt.
Only confirmed in-scope defects enter the fix set. Keep unresolved hypotheses
visible; do not silently downgrade them to achieve a clean verdict.

Audit existing human review concerns after independent discovery: original link
and relevant original-language quote, current code, test evidence, reply accuracy,
and addressed/partial/open/not-applicable status. A resolved thread or posted
reply does not establish correctness. Draft replies without posting them.

### 4. Apply mode and revalidate

Without `--fix`, report findings and proposed corrections; do not edit project
code, commit, push, or change MR state.

With `--fix`, implement confirmed in-scope corrections in isolated writable
worktrees after both discovery rounds and cross-validation. State each intended
correction before editing. Reviewers remain read-only; implementation agents
receive non-overlapping assignments. Escalate genuine product decisions and
scope expansion. Add meaningful regression coverage where behavior warrants it,
and run applicable checks against real dependencies where feasible. Never weaken
tests to make checks pass.

Use at most two repair/revalidation cycles. After each correction, fresh reviewers
inspect the delta and connected code, verify original findings, and check for new
defects. If confirmed findings remain after the bound, report them as open.
Do not claim that repeated review proves the absence of all bugs.

Include only commit/push authorization actually granted for the reviewed MRs;
`--fix` alone authorizes local corrections, not external publication. When delivery
is authorized, resolve current targets, follow repository integration and migration
rules, preserve history, and rerun affected checks after integration. Do not assume
every target is main or every repository uses Alembic. No amend or force-push.
If reviewed SHAs change, invalidate affected evidence and review the delta.

When pushed, monitor required CI jobs for the exact final head SHAs, distinguishing
optional failures and policy/approval blockers. Diagnose failures before retries.
Remove Draft status only when authorized by applicable instructions and genuinely
ready. Never merge, deploy, approve MRs, close tickets, resolve discussions, or post
comments through this workflow without separate applicable authorization.

### 5. Evidence and final decision

Save unique artifacts under the workspace review directory using ticket identifier,
timestamp, and a collision-safe suffix (use repository and MR IDs when no ticket
identifier exists). Preserve snapshots, individual reports,
cross-validation, executed commands/results, skipped checks, fix commits, and
comment audits. Separate static, local runtime, staging, and production evidence.
Update ticket logs through the applicable skill when required by workspace rules;
update current system documentation when fixing code requires it, preserving
historical reports. Do not overwrite earlier review evidence.

Use these table shapes for reports; split wide tables rather than omit evidence:

| Report | Columns |
| --- | --- |
| Context and coverage | MR/repo, head SHA, target SHA, covered paths, missing coverage, context exposure |
| Independent finding | ID, round/reviewer/skill, severity, file:line, trigger, expected/actual behavior, evidence |
| Cross-validation | Root cause ID, source finding IDs, challenger, verdict, evidence, scope, smallest correction |
| Fix tracking | Finding ID, correction, commit/diff, regression command/result, fresh review, remaining issue |
| Human concerns | Comment link/quote, code evidence, runtime evidence, reply accuracy, status, draft reply link |
| Checks | Exact command/job URL, SHA, environment, outcome/counts, failures/skips, limitation |
| Final decision | Dimension, verdict, evidence, blocker/unknown, next action |

Give separate final decisions for implementation correctness, human-review
readiness, GitLab merge eligibility, and deployment confidence. State whether
confirmed in-scope findings remain and whether every existing concern has an
accurate response draft or posted reply. Unknown evidence stays unknown.

## Completion check

- Prompt contains real context addresses, mode, permissions, and missing inputs.
- No author reasoning or historical verdicts leaked into discovery instructions.
- Two fresh discovery rounds precede cross-validation and any fixes.
- Findings require evidence, not votes; repair cycles have a stopping bound.
- Reports use tables and distinguish reviewed SHAs, evidence levels, and unknowns.
