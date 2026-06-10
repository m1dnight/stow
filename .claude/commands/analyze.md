---
description: Audit code for violations of common software engineering principles
argument-hint: [path or file glob, defaults to lib/]
allowed-tools: Read, Grep, Glob, Bash(mix:*), Bash(find:*), Bash(wc:*)
---

# Code Principle Audit

Analyze the Elixir code at `$ARGUMENTS` (default to `lib/` if empty) for violations
of the following principles. Be specific: cite file paths and line numbers, show
the offending snippet, and explain *why* it's a violation in one or two sentences.

## Principles to check

1. **DRY** — repeated logic, copy-pasted blocks, parallel structures that should
   be one function or behaviour.
2. **Single Responsibility** — modules or functions doing several unrelated things;
   functions whose name uses "and"; modules mixing pure logic with side effects.
3. **High Cohesion / Low Coupling** — modules whose functions don't belong together;
   modules reaching into another module's internals or struct fields directly;
   contexts that depend on each other's private functions.
4. **Separation of Concerns** — business logic mixed into Phoenix controllers,
   Ecto queries scattered across non-context modules, presentation logic in
   schemas.
5. **Make Illegal States Unrepresentable** — booleans or strings used where
   tagged tuples or atoms would prevent invalid combinations; nilable fields
   that imply a missing variant of a sum type; structs that allow combinations
   the domain forbids.
6. **Fail Fast / Let It Crash** — defensive `try/rescue` swallowing errors,
   `case` clauses with catch-all `_` that hide bugs, `{:ok, _} = ...` patterns
   used where pattern matching at the function head would be clearer.
7. **Law of Demeter** — long chains like `user.account.subscription.plan.name`;
   pipelines that reach deep into nested structs rather than asking a module
   to do the work.
8. **Pure functional core** — side effects (DB, HTTP, IO, Logger) buried inside
   what look like pure transformation functions.
9. **Principle of Least Surprise** — misleading function names, functions with
   side effects but no `!` or no `:ok`/`:error` return, modules whose public
   API doesn't match their name.
10. **YAGNI / over-abstraction** — behaviours with one implementation, GenServers
    that hold no state and could be plain modules, premature protocols, config
    knobs nobody uses.
11. **Feature Envy / Information Expert** — code outside a struct's owning
    module that derives values purely from that struct's fields. If a function
    (or a substantial expression inside one) accesses two or more fields of
    `%Foo{}` and synthesizes something from them — a formatted string, a
    derived boolean, an aggregate — that logic belongs in `Foo` as
    `Foo.something(foo)`, not at the call site.

    Heuristics for flagging:
    - An expression references `x.field_a` and `x.field_b` (same `x`) where
      `x` is a struct defined elsewhere in the project.
    - String interpolations, arithmetic, or boolean combinations over multiple
      fields of the same struct, performed outside that struct's module.
    - The same field-combination pattern appears at 2+ call sites (which also
      makes this a DRY violation — double-flag it).

    Suggestion format: "Move this to `<StructModule>.<proposed_name>/1`. The
    function should take the struct as its first argument so it pipes naturally."

    Don't flag:
    - Pattern matching in function heads (`def f(%User{first_name: f})`) —
      that's idiomatic destructuring, not envy.
    - Single-field access (`user.email`) — accessing one field externally is
      fine; the smell is when external code is *synthesizing* across fields.
    - Code inside the owning module itself.
## Workflow

1. Use Glob/Grep to enumerate Elixir source files under the target path.
   Skip `deps/`, `_build/`, `priv/static/`, and test files unless the user
   explicitly included them.
2. Read files in batches. Don't try to load everything at once for large
   codebases — sample strategically (largest modules first, then a random
   selection).
3. For each violation, output an entry in this format:

```
   ### [Principle name] — path/to/file.ex:LINE
   <2-4 line snippet>
   Why: <one or two sentence explanation>
   Suggestion: <concrete fix, not a vague "consider refactoring">
```

4. Group findings by principle, then by severity (high / medium / low) within
   each principle. A "high" finding is one a reviewer would block a PR on.
5. End with a short summary: total count per principle, and the top 3 files
   that show up most often (likely refactor candidates).

## Constraints

- Do not modify any files. This is read-only analysis.
- Don't report stylistic nits that `mix format` or Credo would already catch
  unless they tie into one of the principles above.
- If you're unsure whether something is a violation, say so rather than padding
  the list. False positives are worse than missing items.