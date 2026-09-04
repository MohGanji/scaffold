# Gates

What must be true to commit.

A gate is one script at `scripts/check-<name>.sh`. It holds its own threshold, exits non-zero on failure, and is called by **both** the pre-commit hook and CI. Nothing is implemented twice.

Sibling layers: [`../guardrails/`](../guardrails/) stops an action before it runs. Gates check work already done.

## The architecture matters more than the gate list

- **One script per gate.** The threshold lives in the script, not in the hook and again in CI.
- **Discovery by glob.** The hook and CI both run `scripts/check-*.sh`. Adding a gate is adding a script — no registration, no list to update, nothing to drift. Same principle as the guardrail adapters.
- **Parity is a rule.** Change a gate, a threshold, or a CI job, and update both callers together. A commit that passes locally must pass CI.
- **Install through the package manager.** A fresh clone must be protected without a manual step.
- **Blocking by design.** A warning-only gate is decoration.
- **Ignore files, not exceptions.** Generated and vendored code goes in the gate's ignore file. Never special-case inside the script.

## Install

Copy the hook and point git at it:

```bash
mkdir -p .githooks && cp .agents/gates/pre-commit .githooks/pre-commit
chmod +x .githooks/pre-commit
git config core.hooksPath .githooks
```

Then make it survive a fresh clone. In `package.json`:

```json
{ "scripts": { "prepare": "git config core.hooksPath .githooks" } }
```

No Node? Any bootstrap command works — a `make setup` target, a `[tool.poetry] post-install`, a line in the README's setup block. The requirement is that nobody has to remember.

CI: copy [`ci/github-actions.yml`](ci/github-actions.yml) to `.github/workflows/gates.yml`, or [`ci/gitlab-ci.yml`](ci/gitlab-ci.yml) to `.gitlab-ci.yml`.

## Writing a gate

`scripts/check-<name>.sh`, executable, exits non-zero on failure:

```bash
#!/usr/bin/env bash
# <Gate> gate: one line on what fails the build.
# Single source of truth for the threshold — pre-commit and CI both call this.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

THRESHOLD=30

# ... run the check, print findings on failure ...

echo "<name> check passed."
```

Print findings on failure. The agent reads that output to decide what to fix.

## Where gates come from

Don't hand-write these. The setup skills generate them, wired into both callers:

| Gate | Skill | Checks |
| --- | --- | --- |
| CRAP | `/setup-crap-check` | complexity² × (1−coverage)³ + complexity, per function |
| DRY | `/setup-dry` | structural duplication via AST fingerprinting |
| React | `/setup-react-doctor` | component anti-patterns, re-render cost |
| Lint | your linter | whatever your linter says |
| Tests | your runner | the suite |

Tests are a gate like any other. Wire them in the same way.

## The `## Commands` rule

`AGENTS.md` needs a `## Commands` section listing one command per gate — **before the gates exist**.

An agent needs one documented way to verify its own work before reporting done. That is the load-bearing half of the whole loop, and several skills and automations assume it outright: a bug hunt that must prove every finding with a failing test cannot function without a runner it can name.

## Coverage-dependent gates

CRAP needs coverage data, so each workspace must expose a coverage script producing an Istanbul JSON report. Workspaces without one get skipped with a warning until tests exist — a skip is visible, a silent pass is not.
