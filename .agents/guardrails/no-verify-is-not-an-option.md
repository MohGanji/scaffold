---
name: no-verify-is-not-an-option
description: Blocks any git commit that bypasses the pre-commit quality gates.
event: before-shell
match: 'git[[:space:]]+commit'
deny-when: '--no-verify|(^|[[:space:]])-[[:alpha:]]*n'
action: deny
message: 'Committing with --no-verify (or -n) is never allowed in this repo. Fix what the gate is complaining about — refactor, add the tests — then commit normally. If the gate itself is wrong, change the gate and its CI counterpart together.'
fail: closed
enforces: 'AGENTS.md § Gates — "Never skip pre-commit. Under no condition commit with --no-verify"'
degrades-to: commit-stage
---

# `no-verify` is not an option

A gate you can skip is a suggestion.

The rule stays prose for exactly as long as your earliest enforcement point is the hook itself — and an agent that has just written forty files has every incentive to get *past* a failing gate rather than satisfy it. This guardrail moves enforcement in front of the tool call, where bypassing isn't an available move.

## What a violation looks like

```
git commit --no-verify -m "wip"
git commit -n -m "fix later"
git commit -am "..." --no-verify
```

## What to do instead

The gate names what it found. Run the matching skill — `/cut-the-crap` for CRAP, `/dry` for duplication, `/react-doctor` for React — fix the finding, commit normally.

A gate that is genuinely wrong gets changed in `scripts/` **together with** its CI counterpart, per the parity rule. It never gets bypassed for one commit.

## Known imprecision

`git commit -m "fix the -n flag"` trips this, because the pattern can't tell a flag from a quoted string.

That's the intended trade. Rephrase the message. Do not loosen `deny-when` to make it pass — see the fail-closed section in [`README.md`](README.md).

## Coverage

`before-shell` exists on all three harnesses targeted, so this is enforced at the fast tier everywhere.

The pre-commit hook enforces it regardless. It's the thing being protected, and it also catches the case where the hook never fired.
