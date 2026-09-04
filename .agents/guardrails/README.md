# Guardrails

Deterministic rules that hold **inside the agent loop** — checks that fire *before* a tool call runs, not after the damage is committed.

Each guardrail is **event + match + action**. One markdown file per rule: frontmatter for the machine-readable parts, body for the rationale.

The definitions here are the source of truth. A harness contributes only the hook mechanism; the rule never lives in a harness-specific file. Harness config is **generated** from this folder by the adapters in [`adapters/`](adapters/).

Sibling layers: [`../automations/`](../automations/) wires *when and as whom* an agent runs. [`../skills.md`](../skills.md) points at *how* it works. Guardrails define *what it may not do*.

## Three tiers, and why all of them stay

| Tier | Mechanism | Fires | Failure mode |
| --- | --- | --- | --- |
| **Guardrail** | harness hook | before the tool call runs | agent cannot perform the action at all; it reads the refusal and adapts |
| **Gate** (`scripts/check-*.sh`) | pre-commit + CI | at commit, then again at push | work is already done; the agent's incentive is to get *past* the gate |
| **Convention** (`AGENTS.md`, skills) | prose an agent reads | whenever it remembers | advisory |

A rule written only as prose is a rule that holds most of the time. If `AGENTS.md` has to say *"never skip pre-commit"* twice, the enforcement point is too late.

**The tiers are defence in depth, not a migration.** Adding a guardrail never removes the commit gate, for one concrete reason: **hooks fail open on several harnesses.**

Cursor's `beforeShellExecution` has filed reports of a malformed JSON response [silently allowing the command instead of blocking](https://forum.cursor.com/t/beforeshellexecution-hook-malformed-json-response-silently-allows-command-instead-of-blocking/152669), of a [UTF-8 BOM breaking `JSON.parse()` so guards degrade to allow](https://forum.cursor.com/t/on-windows-cursor-s-hook-stdin-json-payload-includes-a-utf-8-bom-that-breaks-standard-json-parse-causing-security-guards-to-silently-degrade-to-allowing-commands-across-all-agent-channels/166794), and of the [CLI not emitting every configured event](https://forum.cursor.com/t/cursor-cli-doesnt-send-all-events-defined-in-hooks/148316). Claude Code fails open too: exit 0 with malformed JSON is a non-blocking error, and the tool call proceeds.

Two consequences, both binding on adapter authors:

1. **Deny via the fail-closed path.** On Claude Code that means **`exit 2` with the reason on stderr** — never a JSON `permissionDecision`. Exit 2 blocks even when the JSON is invalid, and cannot be overridden.
2. **A guardrail that looks installed may not be enforcing.** So the commit gate stays, and setup emits a coverage report instead of claiming success.

## Fail closed on ambiguity — by design

Matching a shell command with a regex is imprecise. `git commit -m "fix the -n flag"` trips the `--no-verify` rule.

Accept it. A false deny costs one rephrase and prints why. A false allow costs a bypassed gate.

**Never loosen a `deny-when` pattern to remove a false positive.** Narrow the `match`, or accept the rephrase.

## Roster

| Name | Event | Action | Enforces |
| --- | --- | --- | --- |
| [`no-verify-is-not-an-option`](no-verify-is-not-an-option.md) | `before-shell` | deny | `AGENTS.md` § Gates — never bypass the hooks |

One guardrail ships. It's the reliable first case for any repo. Everything else is yours to write.

## Vocabulary

Events are named by meaning, never by a harness's label:

- `before-shell` — a shell command is about to run.
- `before-file-edit` — a file is about to be written or edited.
- `before-mcp-call` — an MCP tool is about to be invoked.

Actions:

- `deny` — refuse and tell the agent why. Must use the harness's fail-closed path.
- `ask` — pause for a human decision, naming the approval route. **Nothing uses this yet.** It's in the vocabulary because it's the one capability the commit tier cannot express: CI can pass or fail, it cannot ask. Reach for it when protected-path sign-off becomes real, not before.

Frontmatter:

| Field | Required | Meaning |
| --- | --- | --- |
| `name` | yes | Matches the filename. |
| `description` | yes | One line. |
| `event` | yes | From the vocabulary above. |
| `match` | yes | Extended-regex prefilter on the command or path string, case-insensitive. |
| `deny-when` | no | Second regex that must *also* match for the action to fire. Absent means fire whenever `match` hits. |
| `action` | yes | `deny` or `ask`. |
| `message` | yes | The agent-facing refusal. One line; say what to do instead. |
| `fail` | yes | `closed` — the only supported value, and the reason for `exit 2` over JSON. Present so a future `open` guardrail must declare itself. |
| `enforces` | yes | The document and section this makes deterministic. A guardrail with nothing to point at is a rule nobody agreed to. |
| `degrades-to` | yes | What still enforces this on a harness with no matching event. Effectively always `commit-stage`, stated per guardrail so the fallback is never assumed. |

`degrades-to` is **unconditional**, not a fallback. The named tier enforces the rule as well, on every harness, always. See the fail-open reasoning above.

## Harness capability matrix

Verified 2026-08-27. Update as harnesses change.

| Harness | Config path | `before-shell` | `before-file-edit` | Actions | Fail-closed path |
| --- | --- | --- | --- | --- | --- |
| **Claude Code** | `.claude/settings.json` → `hooks.PreToolUse` | `matcher: "Bash"` | `matcher: "Edit\|Write"` | `allow` / `deny` / `escalate` | `exit 2` + stderr |
| **Cursor** | `.cursor/hooks.json` | `beforeShellExecution` (regex `matcher`) | `beforeReadFile`, `afterFileEdit` | `allow` / `deny` / `ask` | **none reliable** — see the reports above; treat Cursor as advisory-only and lean on `degrades-to` |
| **Codex CLI** | `hooks.json` or `[hooks]` in `config.toml`; needs `[features].codex_hooks = true` | `PreToolUse`, `matcher: "Bash"` | **not available** — `PreToolUse` intercepts Bash only, by design | intercept/validate | exit-code based |

Read that as the real coverage: only Claude Code enforces `before-file-edit` at the fast tier, and only Claude Code has a documented unconditional block. Everywhere else, `degrades-to` does the work.

Sources: [Claude Code hooks](https://code.claude.com/docs/en/hooks) · [Cursor hooks](https://cursor.com/docs/hooks) · [Codex hooks reference](https://agenticcontrolplane.com/blog/codex-cli-hooks-reference) · [Codex advanced config](https://developers.openai.com/codex/config-advanced)

## Adapter contract

One adapter per harness, in [`adapters/`](adapters/) — **not one per guardrail**. An adapter reads every definition at call time, so adding a guardrail is adding a file. No codegen, no drift.

Each adapter must:

1. Read the harness payload and extract the command (or path) and tool name.
2. Exit "no decision" immediately when the event doesn't apply. Never guess.
3. Walk `*.md` in this folder, skipping `README.md`, keeping definitions whose `event` matches and whose `action` it implements.
4. Deny when `match` hits **and** (`deny-when` is absent **or** also hits).
5. Emit `message` plus the guardrail's name on the fail-closed path.
6. Be silent and exit 0 otherwise. An adapter that errors must not block unrelated work — but must not silently claim to be enforcing either.

**Built:** `adapters/claude.sh`.

**Not built:** Cursor and Codex. Both are mechanical against the contract above. Neither should be trusted until tested against its harness's real payload — an untested adapter on a fail-open harness is worse than none, because it reads as coverage.

## Setup contract

> Install the guardrails defined in `.agents/guardrails/` for &lt;harness&gt;.

The agent generates the harness config from this folder, points it at the adapter, makes it executable, and **reports a coverage table**: per guardrail, enforced at the fast tier on this harness, or fallen through to `degrades-to`.

That report is the deliverable. A silent success is indistinguishable from a fail-open, which is the whole hazard.

For Claude Code the generated config is `.claude/settings.json`, committed so it applies to everyone:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PROJECT_DIR}/.agents/guardrails/adapters/claude.sh",
            "timeout": 10,
            "statusMessage": "Checking guardrails…"
          }
        ]
      }
    ]
  }
}
```

## Testing

Adapters are plain executables reading a payload on stdin, so they test without a harness:

```bash
echo '{"tool_name":"Bash","tool_input":{"command":"git commit --no-verify -m x"}}' | .agents/guardrails/adapters/claude.sh; echo "exit=$?"
```

That must print `exit=2`.

Every guardrail gets both cases exercised — the command it must block, and a near neighbour it must not. `adapters/selftest.sh` runs the whole roster both ways:

```bash
.agents/guardrails/adapters/selftest.sh
```

## Conventions

- One file per guardrail, kebab-case, `name` matches the filename.
- `event` and `action` come from the vocabulary, described by meaning, never by a harness's label.
- Keep the roster and the harness matrix in sync in the same commit as any change.
- A guardrail must name what it `enforces`. New rules get written as prose in `AGENTS.md` or `INVARIANTS.md` first, then made deterministic here. Never invented in this folder.

## What doesn't belong here

- **Anything needing judgment.** That's a skill, invoked by an automation. Guardrails are regexes and exit codes.
- **Anything cheap to check but expensive to run** — test suites, lint, CRAP, DRY. Those are gates in [`../gates/`](../gates/). Hooks at this tier tax every tool call, so they stay fast and scoped.
- **Rules with no document behind them.** See `enforces`.
