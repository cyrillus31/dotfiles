---
name: clarity-from-zero
description: Draft or revise technical explanations for readers who lack project context, or audit a document sentence by sentence for ambiguous actions, undefined terms, missing locations, and misleading implications. Use for requests such as "explain from zero", "assume junior level", or "each sentence must make sense on its own". Ordinary wording cleanup without missing conceptual context belongs to write-concisely.
---

# Clarity from zero

Make technical prose understandable without requiring the reader to reconstruct
unstated system knowledge. Preserve the mechanism, its conditions, and its
limits.

## When to use

Apply when creating a beginner-facing technical explanation or when a reader
reports that an explanation assumes context they do not have. A
sentence-by-sentence
request covers the entire requested document, including tables, callouts,
captions, diagrams, and secondary sections.

This skill addresses missing meaning and misleading mental models. It does not
require shorter text, a fixed document template, or a tutorial for every typo.

## Scope and boundaries

- Edit only requested explanatory content. Reviewing prose does not authorize
  source-code changes, product changes, deployment, or messages to other people.
- Follow the requested format and scope. Preserve the document's language,
  identifiers, requirements, conditions,
  exceptions, and distinctions between implemented, tested, and deployed
  behavior.
- Use supplied facts and relevant sources. If a concrete mechanism is unknown,
  verify the relevant source or name the gap; never invent a path, query, field,
  guarantee, or danger to make a sentence sound complete.
- Treat unclear wording as a document defect, not evidence that the reader lacks
  technical competence. Do not infer comprehension from silence or successful
  editing.

## 1. Establish the frame before the details

Start with the actual problem and its consequence for a person using the
product.
State what the person configured, requested, saw, or could not do. Explain the
system's purpose before naming the mechanism that changes its behavior.

For a multi-part explanation, name the parts before developing them. Group by
the actual questions being answered; do not impose an arbitrary section count.
Carry one concrete example, with the same names and values, through the
explanation.

Descend in order: problem, concept, participating programs and storage, request
or
data flow, then code. Explain a new concept before using syntax to illustrate
it.
Use a clearly labelled everyday example when it helps establish the concept.

## 2. Audit each sentence with five questions

Read each sentence with its surrounding paragraph hidden. Ask what a reader
could
understand, misunderstand, or have to guess. Immediate context can supply a
recent
referent; a distant glossary or previous conversation cannot carry the sentence.

1. **What exactly is the thing?** Distinguish configuration from a network
   connection, a job record from running code, a downloaded copy from its
   original,
   and a numeric vector from its identifier. Replace overloaded nouns with the
   particular thing meant.
2. **What actually happens?** Name the program or function and the concrete
   action:
   reads a column, rejects a request, changes a status, writes a file, returns
   an
   error. "Coordinates", "protects", "handles", and "refuses" need a named
   object
   and an observable operation to explain the mechanism.
3. **Where does it happen?** Locate stored data in a service's database and
   table,
   files on the relevant storage, requests on the receiving service, and code in
   its repository and file. Distinguish an original on a remote server from a
   copy
   on application storage.
4. **What knowledge does the sentence require?** Define a new term or acronym
   before relying on it. Explain what an identifier's components mean. Replace
   unexplained labels such as "authority", "membership", "adoption", or
   "snapshot"
   with their concrete meaning, then introduce the label if it remains useful.
5. **What else does the sentence imply?** Check the mental model a reader would
   naturally build. "Must preserve remote files" can imply that removing a local
   setting might delete those files. Establish the actual operation and its
   scope;
   retain a warning only when evidence supports the risk and it matters here.

When a sentence fails, repair the sentence or the prerequisite definition. Do
not
leave the ambiguous wording and append a disclaimer three paragraphs later.
Delete an unsupported implication rather than inventing a mechanism to explain
it.

For a long document, a temporary numbered sentence list can help prevent skipped
passages. Preserve inline identifiers during splitting; periods inside file
paths
are not sentence endings. Automated splitting finds units to inspect, not
clarity.
Do not claim that a sentence counter or readability score verifies
understanding.

## 3. Make the mechanism reconstructable

Use these rules when the explanation describes behavior or a change:

1. **Trace the relevant path.** Connect the product action to the entry point,
   application functions, storage operations, response, and visible result. Name
   each layer's responsibility. Show relevant request and response fields and
   explain table columns when they are needed to understand the claim. Keep
   unrelated layers out; identify any unverified step.
2. **Keep independent states separate.** A saved failure status, publication
   permission, process termination, and physical erasure are different outcomes.
   Define exactly what a successful response confirms and what remains pending.
   State a guarantee at the boundary the implementation actually enforces.
3. **Show why the mechanism is needed.** First ask whether the cause can be
   removed. If a naive solution fails, show the exact input or sequence that
   defeats it, then the mechanism that survives that failure. Keep separate root
   problems in separate explanations; avoid inventing extra failed approaches.
4. **Compare like with like.** For a change, keep the same example, values, and
   names in before/after explanations. Change only the behavior under
   discussion.
   If diagrams help, use matching nodes and diagram types and highlight the
   changed parts. Diagram labels must make sense without the surrounding prose.

Use literal descriptions before analogies. "The worker polls the job's owner
column until it is NULL" identifies an operation; "the worker waits for its
owner"
leaves the mechanism and even the meaning of "owner" unspecified.

## 4. Restore the reading flow without rebuilding hidden dependencies

After sentence-level repairs, read each section independently, then the document
from beginning to end. Definitions belong before their first necessary use.

Repeat important distinctions through the running example, a comparison, or a
short takeaway. Repetition should reinforce meaning, rather than repeat
identical
wording. Reintroduce the relevant service and stored value at section
boundaries.

Keep one notion per paragraph and one item per list entry. Split sentences that
combine independent claims. Retain a longer sentence when splitting would hide
its condition or causal relationship. Do not repeat an entire glossary in every
sentence merely to eliminate all context.

Move secondary detail into a clearly marked aside or supported collapsed
section.
Do not hide a prerequisite definition or a condition that changes the main
claim.
Remove obsolete wording and duplicated explanations after editing; the document
should describe the system, not narrate the revision process.

## Examples of the failure pattern

These examples demonstrate wording, not facts to assume about another system.
Verify a replacement's mechanism against the target system before using it.

| Unclear sentence | Why it fails | Concrete replacement |
| --- | --- | --- |
| "Removing the Copilot connection must preserve the GitLab files." | Leaves the configured relationship and file location undefined; implies an unexplained remote-deletion risk | "Removing the GitLab group from a Copilot product's source list changes Copilot's configuration. The original repositories remain on the GitLab server." |
| "Removal refuses." | Names neither the rejecting program nor the condition | "Management rejects the group-removal request while that product has a synchronization job recorded as pending or running." |
| "A's identity protects B." | An identifier cannot explain a storage boundary by itself | "Old attempt A and replacement B use different vector-record identifiers, so A's delayed deletion addresses A's records rather than B's." |
| "The service confirms membership." | Hides what is transmitted and what confirmation establishes | "Management sends the search service the complete repository list for the product and checks the returned acknowledgement." |
| "The heartbeat expired, so execution stopped." | Turns absent monitoring evidence into proof of termination | "The job's heartbeat timestamp is older than the recovery threshold. That observation does not establish that the executing process stopped." |

## Verification and handoff

Before claiming the clarity pass is complete, check:

1. **Meaning:** compare with the source. Account for every substantive
   condition,
   exception, and operational limit. Flag any substantive correction separately
   from wording changes; do not quietly turn a pending check into a verified
   result.
2. **Sentences:** inspect the complete requested text, including secondary
   content,
   using the five questions. Each mechanism names concrete behavior, and no
   sentence requires the reader to guess a consequential referent or location.
3. **Reading flow:** open each section alone. Check its starting frame,
   necessary
   definitions, order of concepts, and final takeaway where useful.
4. **Artifacts:** check edited links, tables, fences, and diagram syntax using
   available tools. Distinguish structural checks from actual diagram rendering.

For a saved document, return its link and a brief description of the substantive
clarity repairs. For an inline rewrite, return the revised text without creating
a file. If asked for rules rather than a document rewrite, provide the rules and
examples without editing unrelated documents.
