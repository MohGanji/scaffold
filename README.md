<div align="center">

# scaffold

**Point an agent at this repo. Get a software factory.**

[Website](https://mohganji.github.io/scaffold) · [The installer](.agents/scaffold.md) · [Skills](.agents/skills.md)

</div>

---

Starting a project means rebuilding the same machinery every time. Entry point. Skills. Gates. Hooks. CI. The rules agents keep breaking.

Scaffold is that machinery, in one folder.

```
Read .agents/scaffold.md and set this repo up.
```

Ten phases, one decision at a time. You get an agent entry point, a curated skill set, quality gates wired into both the commit hook and CI, guardrails that fire before a tool call instead of after, and a fleet of cloud agents that moves work from ticket to merge without you dispatching each step.

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

## Install

Copy `.agents/` into your repo. That's the whole payload.

```bash
npx skills@latest add mohganji/skills
```

Then tell your agent to read [`.agents/scaffold.md`](.agents/scaffold.md).

Works on Claude Code, Cursor and Codex. Skills, guardrails and automations are defined once, harness-neutral, and adapted at the edge.

## Verify

```bash
.agents/guardrails/adapters/selftest.sh
```

Every guardrail, both ways — the command it must block, and the near neighbour it must not.

---

MIT
