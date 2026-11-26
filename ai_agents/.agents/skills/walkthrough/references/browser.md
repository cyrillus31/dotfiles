# Optional local browser view

The opening knowledge questionnaire and lesson questions appear directly below
the header and scroll with the page. **Submit answers** shows the review status
until the agent returns feedback and the next open check or lesson. **Picture
so far** stays visible in the left panel.
**Ask for clarification** discusses the current step without advancing it.
In the clarification box, Enter sends the message and Shift+Enter inserts a
line break. The clarification box is disabled and a spinner appears while the
agent prepares the reply.

## Start

1. Resolve the skill directory and create a private temporary directory with
   `mktemp -d`. Pipe the opening step JSON into
   `python3 <skill-dir>/scripts/browser.py publish <step-file>`.
2. Save a private JSON checkpoint beside the step when the agent needs context
   beyond the opening page. Include the goal, proposed subgoals, settings, and
   any verified project facts needed later. Keep answer keys in the checkpoint.
3. Run `python3 <skill-dir>/scripts/browser.py serve <step-file> --cwd
   <project-directory> --model <verified-model-name> --agent-json
   <command-argument-array> --checkpoint <checkpoint-file>` in a long-lived
   command session and open the printed loopback URL. The checkpoint and model
   arguments are optional.
4. Supply a trusted local agent command that reads a prompt from standard input
   and writes its final reply to standard output. Configure the command for
   read-only project access. An adapter outside the skill can translate the
   chosen agent’s flags and output format. Use `--clarifier-json` only when a
   separate command handles clarification. The main agent command handles both
   forms by default.

Use multiple choice by default in the browser. For the 0–5 assessment, set
`phase` to `assessment`, add a short `question_intro` with the scale, and
give each rating item the options `["0","1","2","3","4","5"]`.

When the reader submits answers, the local Python server stores them in the
`submissions` table in the SQLite database beside the initial step. The
server reads the saved answers and invokes the configured agent with them,
the current step, the private checkpoint, and recent clarifications. The
agent returns a JSON object with `step` and `checkpoint` objects. The
server stores the new step and checkpoint in the same submission row and
marks the row applied. The browser polls the server and displays the new
step. A failed review leaves the saved answers available for retry.

Retain the step file, SQLite database, and initial checkpoint together if this
walkthrough may resume. Serve the same step file to restore progress. Set
`phase` to `complete` with no open questions when teaching is complete.
The `answers` command is for inspecting saved answers during troubleshooting.

## Step data

`step`, `title`, and `goal` are required strings. `lesson` and `feedback` are plain text.
`recap` is a list of factual statements. Leave it empty at step 1.
`recap_style` is `cumulative` (default) or `previous_step`.

Use `checks` for questions that collect an answer. Each check has a `prompt`.
Include an `options` list for test mode and vary the position of the correct
answer across checks. Leave out `options` for a freeform answer or a follow-up
that asks the reader to explain a choice. Use the legacy `questions` list of
strings only for display-only prompts. Keep the answer key in the private checkpoint.

This example uses fictional data.

```json
{
  "step": "Step 2 of 5",
  "title": "Find the repository the product can still use",
  "goal": "Explain what removing a group link changes for a product.",
  "recap": ["A product can use repositories through a group link or a direct link."],
  "lesson": "The product service removes the group link from payments-product.",
  "checks": [
    {
      "prompt": "Which repository can payments-product still use through a direct link?",
      "options": ["separately-linked-repo", "group-only-repo"],
      "graphs": [{
        "title": "Links saved before the change",
        "nodes": ["payments-product", "group-only-repo", "separately-linked-repo"],
        "edges": [
          ["payments-product", "uses through the group link", "group-only-repo"],
          ["payments-product", "uses through a direct link", "separately-linked-repo"]
        ]
      }]
    }
  ]
}
```

## Illustrations

Add `graphs` to a lesson, a check, or a clarification reply. Each graph has
a `title`, a list of distinct `nodes`, and `edges` with entries of the form
`[source, relationship, target]`. The browser draws the graph and lists
the relationships in text. Include only relationships established at the
current teaching level and avoid revealing the answer to a pinned check.

Use an existing or generated PNG, JPEG, or WebP illustration when it explains
the idea better. Add `image_b64` (base64-encoded image bytes), `image_type`
(the image media type, such as `image/png`), and `image_alt` (a short text
description) to the relevant lesson, check, or clarification reply. A lesson
image can also use `publish --image <image-path>` with `image_alt` in the
step JSON. Convert diagrams from tools such as Mermaid to a supported raster
image before publishing, or use the built-in relationship graph format.

A clarification command can return plain text or a JSON object containing
`text` and optional `graphs` and image fields. The browser places the
visual next to the clarification that uses it.
