#!/usr/bin/env python3
"""Estimate per-ticket effort and phase-start candidates from local evidence.

Evidence: Claude Code transcripts (~/.claude/projects), prompt history (~/.claude/history.jsonl)
and the user's own commits in the ticket repos. Jira and GitLab MR events are not read here.

Effort model: every human prompt and every own commit attributed to a ticket is a heartbeat;
heartbeats at most --idle-min apart form one block, which ends --tail-min after its last heartbeat.
A minute where n tickets are active gives 1/n to each, and a day whose total exceeds --day-cap-h is
scaled down proportionally across all tickets active that day.
"""

import argparse
import glob
import json
import math
import os
import re
import subprocess
import sys
from collections import defaultdict
from datetime import datetime, timedelta, timezone
from zoneinfo import ZoneInfo

TZ = ZoneInfo("Europe/Moscow")
HOME = os.path.expanduser("~")
PROJECTS_DIR = os.path.join(HOME, ".claude", "projects")
HISTORY_FILE = os.path.join(HOME, ".claude", "history.jsonl")
VAULT_TASKS = os.path.join(HOME, "Documents", "Obsidian", "cloud_ru", "tasks")
CODE_ROOT = os.path.join(HOME, "Projects")
DEFAULT_REPOS = [
    os.path.join(HOME, "Projects", "copilot", "agent"),
    os.path.join(HOME, "Projects", "copilot", "agent-ui"),
]
# Each repo's own `git config user.email` is added to these.
DEFAULT_EMAILS = ["kofedtsov@cloud.ru"]
MAIN_REF = "origin/main"
WEEKDAYS = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
EDIT_TOOLS = {"Edit", "Write", "MultiEdit", "NotebookEdit"}
# Harness-generated "user" messages that are not something the human typed.
SYSTEM_PREFIXES = (
    "<local-command-",
    "<task-notification",
    "<system-reminder",
    "[Request interrupted",
    "This session is being continued",
    "Base directory for this skill",
    "The fork runs",
    "Your claude.ai usage",
    "## Context Usage",
)
SELF_REVIEW_RE = re.compile(r"^(<command-name>)?/(code-review|simplify|security-review)\b|code-critic|self[- ]review", re.IGNORECASE)
INHERIT_WINDOW = timedelta(hours=2)
FIRST_LABELS = ("first_mention", "first_plan_mode", "first_note_edit", "first_code_edit", "first_commit")


def fmt(dt):
    if dt is None:
        return "?"
    local = dt.astimezone(TZ)
    return f"{WEEKDAYS[local.weekday()]} {local:%d.%m.%Y %H:%M}"


def parse_iso(value):
    try:
        return datetime.fromisoformat(value.replace("Z", "+00:00"))
    except (AttributeError, ValueError):
        return None


class Matcher:
    def __init__(self, project_key, aliases):
        self.key_re = re.compile(rf"\b{re.escape(project_key)}-(\d+)\b", re.IGNORECASE)
        self.project_key = project_key.upper()
        self.aliases = aliases

    def keys(self, text):
        if not text:
            return set()
        found = {f"{self.project_key}-{n}" for n in self.key_re.findall(text)}
        for alias, key in self.aliases.items():
            if alias in text:
                found.add(key)
        return found


class Evidence:
    def __init__(self):
        self.heartbeats = defaultdict(list)  # key -> [datetime]
        self.firsts = defaultdict(dict)  # key -> {label: (datetime, detail)}
        self.merges = defaultdict(list)  # key -> [(datetime, repo, subject)]
        self.self_reviews = defaultdict(list)  # key -> [(datetime, prompt excerpt)]

    def first(self, key, label, ts, detail):
        current = self.firsts[key].get(label)
        if current is None or ts < current[0]:
            self.firsts[key][label] = (ts, detail)


def prompt_text(entry):
    if entry.get("type") != "user" or entry.get("isMeta") or entry.get("isSidechain"):
        return None
    origin = entry.get("origin")
    if isinstance(origin, dict) and origin.get("kind") != "human":
        return None
    if entry.get("promptSource") == "system":
        return None
    content = (entry.get("message") or {}).get("content")
    if isinstance(content, list):
        if any(isinstance(part, dict) and part.get("type") == "tool_result" for part in content):
            return None
        content = " ".join(
            part.get("text", "") for part in content if isinstance(part, dict) and part.get("type") == "text"
        )
    if not isinstance(content, str):
        return None
    text = content.strip()
    if not text or text.startswith(SYSTEM_PREFIXES):
        return None
    return text


def assistant_parts(entry):
    if entry.get("type") != "assistant" or entry.get("isSidechain"):
        return []
    content = (entry.get("message") or {}).get("content")
    return [part for part in content or [] if isinstance(part, dict)]


def resolve_prompt_keys(prompts):
    """A prompt naming no ticket takes the keys of the nearest keyed prompt, either side, within the same
    stretch of the session; a pause longer than INHERIT_WINDOW starts a new stretch."""
    resolved = [keys for _, keys, _, _ in prompts]
    stretch, stretches = 0, []
    for i, (ts, _, _, _) in enumerate(prompts):
        if i and ts - prompts[i - 1][0] > INHERIT_WINDOW:
            stretch += 1
        stretches.append(stretch)
    keyed = [i for i, keys in enumerate(resolved) if keys]
    for i, (ts, keys, _, _) in enumerate(prompts):
        if keys:
            continue
        candidates = [j for j in keyed if stretches[j] == stretches[i]]
        if candidates:
            nearest = min(candidates, key=lambda j: abs(prompts[j][0] - ts))
            resolved[i] = prompts[nearest][1]
    return resolved


def scan_transcripts(matcher, evidence):
    for path in sorted(glob.glob(os.path.join(PROJECTS_DIR, "*", "*.jsonl"))):
        session = os.path.basename(path)
        prompts = []  # (ts, own keys, permission mode, text)
        code_edits = []  # (ts, index of the preceding prompt, location keys, file path)
        with open(path, errors="ignore") as handle:
            for line in handle:
                try:
                    entry = json.loads(line)
                except json.JSONDecodeError:
                    continue
                ts = parse_iso(entry.get("timestamp"))
                if ts is None:
                    continue
                location_keys = matcher.keys(entry.get("gitBranch") or "") or matcher.keys(
                    os.path.basename(entry.get("cwd") or "")
                )

                text = prompt_text(entry)
                if text is not None:
                    text_keys = matcher.keys(text)
                    for key in text_keys:
                        evidence.first(key, "first_mention", ts, f"prompt in {session}")
                    prompts.append((ts, text_keys or location_keys, entry.get("permissionMode"), text))
                    continue

                # Tool results are skipped: a `git branch -a` listing would "mention" every ticket.
                for part in assistant_parts(entry):
                    if part.get("type") == "text":
                        for key in matcher.keys(part.get("text")):
                            evidence.first(key, "first_mention", ts, f"assistant in {session}")
                        continue
                    if part.get("type") != "tool_use" or part.get("name") not in EDIT_TOOLS:
                        continue
                    file_path = (part.get("input") or {}).get("file_path") or ""
                    if file_path.startswith(VAULT_TASKS):
                        for key in matcher.keys(file_path):
                            evidence.first(key, "first_note_edit", ts, os.path.relpath(file_path, VAULT_TASKS))
                    elif file_path.startswith(CODE_ROOT):
                        code_edits.append((ts, len(prompts) - 1, location_keys, file_path))

        resolved = resolve_prompt_keys(prompts)
        for (ts, _, mode, text), keys in zip(prompts, resolved):
            for key in keys:
                evidence.heartbeats[key].append(ts)
                if mode == "plan":
                    evidence.first(key, "first_plan_mode", ts, text[:60])
                if SELF_REVIEW_RE.search(text):
                    evidence.self_reviews[key].append((ts, text[:60]))
        for ts, index, location_keys, file_path in code_edits:
            keys = (resolved[index] if index >= 0 else set()) or location_keys
            for key in keys:
                evidence.first(key, "first_code_edit", ts, os.path.relpath(file_path, CODE_ROOT))


def scan_history(matcher, evidence):
    if not os.path.exists(HISTORY_FILE):
        return
    with open(HISTORY_FILE, errors="ignore") as handle:
        for line in handle:
            try:
                entry = json.loads(line)
                ts = datetime.fromtimestamp(int(entry["timestamp"]) / 1000, tz=timezone.utc)
            except (json.JSONDecodeError, KeyError, ValueError):
                continue
            text = entry.get("display") or ""
            if text.startswith("/"):
                continue
            for key in matcher.keys(text):
                evidence.heartbeats[key].append(ts)
                evidence.first(key, "first_mention", ts, "history.jsonl")


def git(repo, *args):
    result = subprocess.run(["git", "-C", repo, *args], capture_output=True, text=True)
    return result.stdout if result.returncode == 0 else ""


def scan_git(matcher, evidence, repos, extra_emails):
    for repo in repos:
        if not os.path.isdir(repo):
            continue
        name = os.path.basename(repo)
        emails = {e.lower() for e in extra_emails}
        emails.add(git(repo, "config", "user.email").strip().lower())
        emails.discard("")
        seen = set()

        def own_commits(*rev_args):
            output = git(repo, "log", "--no-merges", "--format=%aI%x1f%ae%x1f%s", *rev_args)
            for line in output.splitlines():
                author_iso, email, subject = line.split("\x1f", 2)
                if email.lower() in emails:
                    yield author_iso, subject

        def record(keys, author_iso, subject):
            ts = parse_iso(author_iso)
            # Rebased copies of a commit differ in hash but keep author date and subject.
            if ts is None or (author_iso, subject) in seen:
                return
            seen.add((author_iso, subject))
            for key in keys:
                evidence.heartbeats[key].append(ts)
                evidence.first(key, "first_commit", ts, f"{name}: {subject[:60]}")

        for author_iso, subject in own_commits("--branches", "--remotes"):
            keys = matcher.keys(subject)
            if keys:
                record(keys, author_iso, subject)

        # Commits without a key in the subject belong to the ticket named by their branch. A branch
        # stacked on another contains the lower branch's commits too, so shorter branches claim first.
        refs = git(repo, "for-each-ref", "--format=%(refname:short)", "refs/heads", "refs/remotes")
        branch_commits = [
            (matcher.keys(ref), list(own_commits(ref, f"^{MAIN_REF}"))) for ref in refs.splitlines() if matcher.keys(ref)
        ]
        for ref_keys, commits in sorted(branch_commits, key=lambda item: len(item[1])):
            for author_iso, subject in commits:
                if not matcher.keys(subject):
                    record(ref_keys, author_iso, subject)

        merges = git(repo, "log", MAIN_REF, "--first-parent", "--merges", "--format=%H%x1f%cI%x1f%s")
        for line in merges.splitlines():
            sha, committer_iso, subject = line.split("\x1f", 2)
            ts = parse_iso(committer_iso)
            keys = matcher.keys(subject)
            if ts is None or not keys:
                continue
            for key in keys:
                evidence.merges[key].append((ts, name, subject))
            # A merged branch may be deleted; its commits stay reachable through the merge's second parent.
            for author_iso, commit_subject in own_commits(f"{sha}^1..{sha}^2"):
                if not matcher.keys(commit_subject):
                    record(keys, author_iso, commit_subject)


def blocks(times, idle, tail):
    times = sorted(times)
    if not times:
        return []
    result = [[times[0], times[0], 1]]
    for ts in times[1:]:
        if ts - result[-1][1] <= idle:
            result[-1][1] = ts
            result[-1][2] += 1
        else:
            result.append([ts, ts, 1])
    return [(start, end + tail, count) for start, end, count in result]


def compute(evidence, idle, tail, day_cap_minutes):
    ticket_blocks = {key: blocks(beats, idle, tail) for key, beats in evidence.heartbeats.items()}
    minute_owners = defaultdict(set)
    for key, key_blocks in ticket_blocks.items():
        for start, end, _ in key_blocks:
            for minute in range(math.floor(start.timestamp() / 60), math.ceil(end.timestamp() / 60)):
                minute_owners[minute].add(key)

    raw = defaultdict(lambda: defaultdict(float))
    overlap = defaultdict(lambda: defaultdict(int))
    for minute, owners in minute_owners.items():
        day = datetime.fromtimestamp(minute * 60, tz=TZ).date()
        for key in owners:
            raw[key][day] += 1 / len(owners)
            if len(owners) > 1:
                overlap[key][day] += 1

    day_totals = defaultdict(float)
    for days in raw.values():
        for day, minutes in days.items():
            day_totals[day] += minutes
    factors = {day: min(1.0, day_cap_minutes / total) for day, total in day_totals.items() if total}
    capped = {key: {day: minutes * factors[day] for day, minutes in days.items()} for key, days in raw.items()}
    return ticket_blocks, raw, capped, overlap, day_totals, factors


def summarize(key, evidence, ticket_blocks, capped, overlap):
    beats = sorted(evidence.heartbeats.get(key, []))
    firsts = evidence.firsts.get(key, {})
    merges = sorted(evidence.merges.get(key, []))
    days = capped.get(key, {})
    active_minutes = sum(days.values())
    starts = [ts for ts in [firsts.get("first_mention", (None,))[0], beats[0] if beats else None] if ts]
    ends = [ts for ts in [beats[-1] if beats else None, merges[-1][0] if merges else None] if ts]
    start, end = min(starts, default=None), max(ends, default=None)
    return {
        "key": key,
        "firsts": {
            label: {"at": fmt(ts), "iso": ts.isoformat(), "detail": detail} for label, (ts, detail) in firsts.items()
        },
        "merges_into_main": [
            {"at": fmt(ts), "iso": ts.isoformat(), "repo": repo, "subject": subject} for ts, repo, subject in merges
        ],
        "self_review_prompts": [
            {"at": fmt(ts), "iso": ts.isoformat(), "prompt": prompt}
            for ts, prompt in sorted(evidence.self_reviews.get(key, []))
        ],
        "heartbeats": len(beats),
        "blocks": len(ticket_blocks.get(key, [])),
        "first_activity": fmt(beats[0]) if beats else "?",
        "last_activity": fmt(beats[-1]) if beats else "?",
        "calendar_span_days": round((end - start).total_seconds() / 86400, 1) if start and end else None,
        "active_hours": round(active_minutes / 60, 1),
        "workdays": round(active_minutes / 60 / 8, 2),
        "overlap_hours": round(sum(overlap.get(key, {}).values()) / 60, 1),
        "active_days": [
            {"date": f"{WEEKDAYS[day.weekday()]} {day:%d.%m.%Y}", "hours": round(minutes / 60, 2)}
            for day, minutes in sorted(days.items())
            if minutes >= 1
        ],
    }


def print_summary(summary):
    print(f"== {summary['key']}")
    for label in FIRST_LABELS:
        item = summary["firsts"].get(label)
        print(f"  {label:<16} {item['at'] if item else '?':<22} {item['detail'] if item else ''}")
    for item in summary["self_review_prompts"]:
        print(f"  {'self_review':<16} {item['at']:<22} {item['prompt']}")
    for merge in summary["merges_into_main"]:
        print(f"  {'merge→main':<16} {merge['at']:<22} {merge['repo']}: {merge['subject'][:70]}")
    print(
        f"  activity {summary['first_activity']} → {summary['last_activity']} · "
        f"calendar {summary['calendar_span_days']} d · active {summary['active_hours']} h "
        f"({summary['workdays']} workdays of 8 h) · overlapped {summary['overlap_hours']} h · "
        f"{summary['heartbeats']} heartbeats in {summary['blocks']} blocks"
    )
    for day in summary["active_days"]:
        print(f"    {day['date']}  {day['hours']:.2f} h")


def print_debug_day(day, ticket_blocks, raw, capped, day_totals, factors):
    print(f"== debug {WEEKDAYS[day.weekday()]} {day:%d.%m.%Y}")
    print(f"  all tickets raw total {day_totals.get(day, 0) / 60:.2f} h · cap factor {factors.get(day, 1.0):.2f}")
    for key in sorted(raw):
        if day not in raw[key]:
            continue
        print(f"  {key}: raw {raw[key][day] / 60:.2f} h → counted {capped[key][day] / 60:.2f} h")
        for start, end, count in ticket_blocks[key]:
            if day in (start.astimezone(TZ).date(), end.astimezone(TZ).date()):
                print(f"    {start.astimezone(TZ):%H:%M}–{end.astimezone(TZ):%H:%M}  {count} heartbeats")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("keys", nargs="+", help="ticket keys to report, e.g. AISDLC-611")
    parser.add_argument("--project-key", default="AISDLC")
    parser.add_argument("--alias", action="append", default=[], help="TEXT=KEY: count TEXT as a mention of KEY")
    parser.add_argument("--repo", action="append", help="git repo to scan (repeatable); default: copilot agent + agent-ui")
    parser.add_argument("--email", action="append", default=[], help="extra author email that is the user (repeatable)")
    parser.add_argument("--idle-min", type=int, default=30)
    parser.add_argument("--tail-min", type=int, default=15)
    parser.add_argument("--day-cap-h", type=float, default=8)
    parser.add_argument("--debug-day", help="YYYY-MM-DD: print every ticket's blocks for that day")
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()

    aliases = {}
    for item in args.alias:
        text, _, key = item.partition("=")
        if not key:
            parser.error(f"--alias expects TEXT=KEY, got {item!r}")
        aliases[text] = key.upper()
    matcher = Matcher(args.project_key, aliases)

    evidence = Evidence()
    scan_transcripts(matcher, evidence)
    scan_history(matcher, evidence)
    scan_git(matcher, evidence, args.repo or DEFAULT_REPOS, DEFAULT_EMAILS + args.email)

    ticket_blocks, raw, capped, overlap, day_totals, factors = compute(
        evidence, timedelta(minutes=args.idle_min), timedelta(minutes=args.tail_min), args.day_cap_h * 60
    )
    summaries = [summarize(key.upper(), evidence, ticket_blocks, capped, overlap) for key in args.keys]

    if args.json:
        json.dump(summaries, sys.stdout, ensure_ascii=False, indent=2)
        print()
    else:
        for summary in summaries:
            print_summary(summary)
    if args.debug_day:
        print_debug_day(
            datetime.strptime(args.debug_day, "%Y-%m-%d").date(), ticket_blocks, raw, capped, day_totals, factors
        )


if __name__ == "__main__":
    main()
