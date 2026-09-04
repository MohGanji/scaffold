<div align="center">

# scaffold

**Point an agent at this repo. Get a software factory.**

[Website](https://mohganji.github.io/scaffold) · [The installer](.agents/scaffold.md) · [Skills](.agents/skills.md)

</div>

---

Starting a project means rebuilding the same machinery every time. Entry point. Skills. Gates. Hooks. CI. The rules agents keep breaking.

Scaffold is that machinery, in one folder.

Send this to your agent, in any repo:

```
set https://github.com/MohGanji/scaffold up
```

It does the rest — pulls the folder in, installs the skills, wires the hooks and CI, and walks ten phases one decision at a time. You answer questions.

What you end up with: an agent entry point, a curated skill set, quality gates wired into both the commit hook and CI, guardrails that fire before a tool call instead of after, and a fleet of cloud agents that moves work from ticket to merge without you dispatching each step.

## Four layers

| Layer | Question it answers |
| --- | --- |
| [**Skills**](.agents/skills.md) | *How* is the work done? |
| [**Guardrails**](.agents/guardrails/) | What may an agent *never* do? |
| [**Gates**](.agents/gates/) | What must be true to *commit*? |
| [**Automations**](.agents/automations/) | *When*, and as *whom*, does an agent run? |

Keep them separate and none of them rots.

## Three things that make it work

**Skills are borrowed, never vendored.** Scaffold ships a list, not files. A forked skill is a stale copy — the lockfile tells you *that* upstream changed, never what it broke.

**Automations ship as patterns, not instances.** Every ticket key and host path inside an automation belongs to the repo that wrote it. A copied one still pointing at another project's epic will file your tickets there. So you derive yours.

**Guardrails fail closed.** Hooks fail *open* on more than one harness — malformed JSON silently allows the command. So the deny path is `exit 2`, the commit gate never goes away, and setup reports a coverage table instead of claiming success.

## Works everywhere

Claude Code, Cursor, Codex. Skills, guardrails and automations are defined once, harness-neutral, and adapted at the edge.

`.agents/` is the whole payload — the agent copies it in and never needs this repo again.

## Verify

```bash
.agents/guardrails/adapters/selftest.sh
```

Every guardrail, both ways — the command it must block, and the near neighbour it must not.

---

MIT
