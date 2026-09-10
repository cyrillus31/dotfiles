---
name: gitlab
description: Work with GitLab using glab CLI and REST API. Use when the user asks about GitLab operations — MRs, issues, pipelines, CI, repositories, groups, or any GitLab integration.
when_to_use: Tasks involving merge requests, reviews, issues, pipelines, CI/CD, or GitLab repos.
---

# GitLab

## Auth

- Use `GITLAB_API_TOKEN` environment variable for authentication.
- `glab` reads `GITLAB_TOKEN`. If `GITLAB_API_TOKEN` is the only var set, export `GITLAB_TOKEN=$GITLAB_API_TOKEN` or run `glab auth login --token $GITLAB_API_TOKEN` once.
- For direct API calls use the `PRIVATE-TOKEN` header.

## Tool preference

- Prefer the `glab` CLI for any operation it supports.
- If a feature is not available via `glab`, fall back to the GitLab REST API directly:
  - `curl --header "PRIVATE-TOKEN: $GITLAB_API_TOKEN" "https://gitlab.com/api/v4/<endpoint>"`
  - Adjust the base URL for a self-hosted instance.

## Common glab commands

### MRs
```
glab mr list [--assignee @me] [--state all]
glab mr create --title "..." --description "..." [--source-branch ...] [--target-branch ...] [--yes]
glab mr view <id-or-branch>
glab mr checkout <id>
glab mr approve <id>
glab mr merge <id> [--delete-source-branch]
glab mr close <id>
glab mr diff <id>
glab mr update <id> --title "..." --description "..."
```

### Issues
```
glab issue list
glab issue create --title "..." --description "..."
glab issue view <id>
glab issue close <id>
glab issue update <id> --label "bug, high"
```

### Pipelines / CI
```
glab ci list             # recent pipelines for current project
glab ci view <id>
glab ci status
glab ci retry <id>       # retry failed jobs
glab ci trace <job-id>   # view job log
```

### Repos & misc
```
glab repo view <namespace/repo>
glab release list / create
glab label list / create
glab todo list
glab variable list / set / unset   # CI/CD variables
glab ssh-key add
```

## API fallback patterns

When glab lacks a feature, tag it and call the API directly:

```
curl --header "PRIVATE-TOKEN: $GITLAB_API_TOKEN" \
  https://gitlab.com/api/v4/[projects|groups]/<id>/[pipelines|issues|merge_requests|variables|...]
```

Useful endpoints:
- `GET /projects/:id` — project details
- `GET /projects/:id/repository/files/:path/raw?ref=:branch` — file content
- `GET /projects/:id/pipelines?ref=main` — pipeline runs
- `GET /projects/:id/jobs/:job_id/trace` — full job log (glab truncates)
- `GET /projects/:id/variables` — CI variables (glab needs admin; API can list with `GITLAB_API_TOKEN`)
- `PUT/POST/DELETE` for mutations not covered by glab — pass JSON bodies via `-d`.

## Getting project/group IDs

Use URL-encoded path:
- `%2F` is `/` — e.g. `1234` or `namespace%2Frepo` both work as `:id`.