---
description: Scan the codebase for environment variable usage and sync a documentation table in README.md
argument-hint: "[optional path to scan, defaults to repo root]"
allowed-tools: Grep, Glob, Read, Edit, Bash(rg:*), Bash(grep:*)
---

# Document environment variables

Scan the project for every environment variable the code reads, then **create or update** a documentation table in `README.md`. The goal is to *sync*, not regenerate — never throw away work a human already wrote.

## 1. Find every environment variable

Search scope: `$ARGUMENTS` if provided, otherwise the repository root. Exclude dependency/build dirs: `node_modules`, `.git`, `dist`, `build`, `out`, `vendor`, `.venv`, `target`, `.next`.

Look for these access patterns across languages:

- **JS / TS:** `process.env.NAME`, `process.env['NAME']`, `import.meta.env.NAME`
- **Python:** `os.environ['NAME']`, `os.environ.get('NAME')`, `os.getenv('NAME')`
- **Go:** `os.Getenv("NAME")`, `os.LookupEnv("NAME")`
- **Ruby:** `ENV['NAME']`, `ENV.fetch('NAME')`
- **Java / Kotlin:** `System.getenv("NAME")`
- **PHP:** `getenv('NAME')`, `$_ENV['NAME']`, `$_SERVER['NAME']`
- **Rust:** `std::env::var("NAME")`, `env::var("NAME")`
- **C#:** `Environment.GetEnvironmentVariable("NAME")`
- **Shell / Dockerfile / CI yaml:** `$NAME`, `${NAME}`, `ENV NAME=`, `ARG NAME=`
- **`.env`, `.env.example`, `.env.sample`:** every `NAME=` key

Collect the **unique** variable names. For each, note for your own reference:
- The file(s) where it appears
- Any default supplied at the call site (e.g. `os.getenv("PORT", "8080")` → default `8080`)
- Whether it looks **required** (no default, app fails without it) or **optional**

## 2. Check README.md for an existing table

Read `README.md`. Decide whether it already contains a table documenting env vars — look for a section heading like *Environment Variables*, *Configuration*, *Env*, or any markdown table whose header includes a column like `Variable`, `Name`, `Env`, or `Key`.

### If a table already exists
- **Preserve every existing row and all hand-written content** (descriptions, defaults, required flags, notes). Do **not** overwrite a human-written description with a generated one.
- **Append a new row** for any variable found in code but missing from the table. Fill in what you can infer (default, required/optional); prompt the user for extra input if you cannot infer it yourself.
- For variables in the table but **no longer found** in code: do **not** delete them — they may be set in deployment rather than read in source. Flag them in your final summary as "possibly unused — review." Prompt the user if they want to remove them from the table.
- Keep the existing column structure and row ordering; only append.
- Apply the change in place with the Edit tool.

### If no table exists
- Do **not** silently insert one. **Stop and ask the user** whether to add a table and where (a new `## Environment Variables` section, or an existing Configuration section).
- Show a preview of the proposed table for approval.
- Only write to `README.md` after they confirm.

## 3. Table format

Use this unless an existing table dictates otherwise:

| Variable       | Required | Default | Description |
| -------------- | -------- | ------- | ----------- |
| `DATABASE_URL` | Yes      | —       | TODO        |
| `PORT`         | No       | `8080`  | TODO        |

## 4. Report

Finish with a short summary:
- Total variables found
- New rows added
- Any flagged as possibly unused
- Any rows left with a `TODO` description for the user to complete