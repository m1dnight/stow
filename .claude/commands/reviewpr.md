---
description: Adversarial PR review — one subagent per modified file × focus (performance/security/integrity)
argument-hint: [audit-slug] [base-branch]
allowed-tools: Bash(git:*), Read, Grep, Glob, Write, Task
---

You are running an **adversarial** review of a pull request. Be hostile to the change: assume it is broken, insecure, and slow until proven otherwise. Your job is to find problems, not to praise the work.

## Inputs

- **Audit slug:** `$1` — used for the output path. If this is blank, derive a short kebab-case slug from the current branch name.
- **Base branch:** `$2` — the branch this PR was built off of. If this is blank, use `main`.

## Step 1 — Establish the diff

Run git yourself to determine the exact set of files this PR changed, relative to where it forked from the base branch:

1. `git merge-base <base-branch> HEAD` to find the fork point.
2. `git diff --name-only <merge-base>...HEAD` to get the changed files.
3. `git diff <merge-base>...HEAD` to read the actual changes.

Treat the changed-file list as the **authoritative scope**. Don't review files outside it, except to read them for context.

## Step 2 — Fan out subagents

Launch **one subagent per (changed file × focus area)**. The three focus areas are:

- **performance** — algorithmic complexity, N+1 queries, unbounded loops/allocations, blocking I/O on hot paths, missing pagination/limits, lock contention, regressions vs. the prior implementation.
- **security** — authn/authz gaps, injection, SSRF, unsafe deserialization, secrets handling, input validation, IDOR, missing rate limits, risky dependencies.
- **integrity** — correctness, data consistency, transactionality/atomicity, error handling, race conditions, idempotency, edge cases, schema/migration safety.

So if the PR touches 4 files, launch 12 subagents. Run them concurrently.

Give each subagent:
- the path of its **single** file and the **single** focus it owns,
- the diff for that file, plus permission to read the whole file and neighboring code for context,
- the instruction to review adversarially and report only real, defensible findings — no filler, no style nits unless they actually cause one of the three problem classes.

Each subagent returns a list of findings. A finding contains: a one-line title, severity (critical / high / medium / low), file and line(s), why it's a problem, a concrete failing scenario, and a suggested fix.

## Step 3 — Assemble the reports

Collect every subagent's findings and write **three** files:

- `docs/audit/pr/$1/performance.md`
- `docs/audit/pr/$1/security.md`
- `docs/audit/pr/$1/integrity.md`

(If `$1` was blank, use the slug you derived in Step 1.)

Do the writing yourself from the returned findings — do **not** let subagents write these shared files directly, because multiple agents writing the same file concurrently will clobber each other.

Every finding gets a **unique identifier in its header**, scoped to the focus and numbered sequentially. Use `PERF-NNN`, `SEC-NNN`, `INT-NNN`. IDs must be unique across the whole audit. Format each finding like:

```
### [SEC-003] Missing authorization check on bulk nullify

- **Severity:** High
- **Location:** `handlers/nullify.go:88-104`
- **Problem:** <what is wrong>
- **Failing scenario:** <concrete way it breaks / is exploited>
- **Fix:** <concrete remediation>
```

Each report starts with a short header: the branch/PR under review, the base branch, the date, and a one-line count of findings by severity. Order findings by severity, highest first. If a focus found nothing in a given file, state that explicitly rather than omitting it — silence shouldn't be mistaken for a clean bill of health.

## Step 4 — Summarize

After writing the files, print a terse summary to the chat: total findings per focus and per severity, and call out any criticals that should block the merge.