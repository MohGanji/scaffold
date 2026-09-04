# Scaffold

Turn a repo into a software factory. Entry point, skills, gates, guardrails, domain docs, and a fleet of cloud agents that move work from ticket to merge.

This file is the installer.

## Getting here

**If you were pointed at this from another repo** — the user said something like *"set https://github.com/MohGanji/scaffold up in this repo"* — you're reading this remotely. Bring it in first, then start at Phase 0:

```bash
git clone --depth 1 https://github.com/MohGanji/scaffold /tmp/scaffold
cp -R /tmp/scaffold/.agents <target-repo>/
rm -rf /tmp/scaffold
```

That's the whole payload. The target repo never needs this repo again.

Don't copy `README.md`, `site/` or the workflow in `.github/` — those belong to scaffold itself, not to the repo you're setting up.

**If `.agents/` is already here**, you're in the right place. Start at Phase 0 — or, if the factory is already built, see *Updating* below.

## Updating a factory that already exists

Point an agent back here whenever you want the newest version:

> update the factory in this repo from https://github.com/MohGanji/scaffold

**`.agents/` is the entire comparison surface.** Nothing generated ever lands in it — that's what [`.agents-workshop/`](workshop.md) is for — so a diff against upstream is meaningful instead of noise.

1. Shallow-clone scaffold to a scratch directory.
2. `diff -ru <repo>/.agents /tmp/scaffold/.agents`.
3. Sort every difference into three buckets and report them:

| Bucket | Meaning | Default |
| --- | --- | --- |
| **Upstream only** | New guardrail, revised convention, fresh platform finding | Offer it |
| **Local only** | Your automations, your guardrails, your environments | Keep, always |
| **Both changed** | Upstream revised something you also edited | One decision at a time |

4. Apply what the user picks. Commit that on its own.

**Never blind-copy `.agents/` over an existing one.** The automations you derived in Phase 8 and the guardrails you wrote in Phase 6 live there, and upstream ships none of them. "Local only" is the expected state for those folders, not a problem to fix.

`.agents-workshop/` is never part of an update. It's yours; upstream has nothing to say about it.

## The four layers

Each answers one question. Keep them separate and none of them rots.

| Layer | Question | Lives in |
| --- | --- | --- |
| **Skills** | *How* is the work done? | Borrowed. See [`skills.md`](skills.md). |
| **Guardrails** | What may an agent *never* do? | [`guardrails/`](guardrails/) |
| **Gates** | What must be true to *commit*? | [`gates/`](gates/) |
| **Automations** | *When*, and as *whom*, does an agent run? | [`automations/`](automations/) |

Skills are the only layer this repo does not contain. They are borrowed from their sources at setup time — forking someone's skill into your repo buys you a stale copy and nothing else.

Alongside the four layers sits one *place*: [`.agents-workshop/`](workshop.md), where agent output that isn't the product goes — videos, research, prototypes, reports. Not a layer, just a folder with a rule.

## How to run this

**A conversation, not a script.** Explore what exists, report it, take one decision at a time, write. Never assume the repo is empty. Never batch ten questions.

Per phase:

1. **Explore** — read what's there. Report it, including "nothing".
2. **Decide** — lead with the recommendation so the user can accept in a word. Explain only where the choice genuinely branches. Skip a phase when exploration settles it, and say so.
3. **Write** — show the draft, let the user edit, then write.
4. **Commit** — that phase alone, before moving on.

Phases 0–5 are the foundation, in order. 6–9 can wait; a repo with an entry point, skills, gates and docs already earns its keep.

**Do not do 8 before 5.** Review agents with no gates to lean on produce opinion instead of evidence.

---

## Phase 0 — Preflight

**Goal.** Know what repo this is.

**Explore.** `git remote -v` — the host decides `gh` vs `glab`. Language and package manager. Existing `AGENTS.md` / `CLAUDE.md` / `README.md`. Whether `docs/`, ADRs, `.githooks/` or CI config exist. Whether this repo stays standalone or migrates into a monorepo later.

**Decide.**
- **Host** — inferred, confirm it.
- **Incubator?** If this code later moves into a larger monorepo, Phase 4 changes: paths get mirrored, configs get hard-copied from the target instead of invented.

**Done when** host and incubator status are confirmed.

---

## Phase 1 — Entry point

**Goal.** One file every agent reads at session start, in every harness.

**Explore.** Does `AGENTS.md` or `CLAUDE.md` exist? Is either a symlink? Anything worth keeping?

**Decide.** `AGENTS.md` is canonical. `CLAUDE.md` is a symlink to it:

```bash
ln -s AGENTS.md CLAUDE.md
```

Codex and Cursor read `AGENTS.md`. Claude Code reads `CLAUDE.md`. One file, no drift.

**Write.** Aim for one page. This file is spent from every session's context budget, so it carries pointers, not content:

- What this repo is, in two sentences, and where the detail lives.
- Work tracking: tracker, host, PR tool, the default that every new ticket starts from a spec.
- Structure rules (Phase 4), gates (Phase 5), guardrails (Phase 6).
- Simplicity principles — YAGNI, single interfaces, name by identity not mechanics.
- A skill index, if the harness doesn't list skills itself.

Add sections as later phases land. Don't write placeholders now.

**Optional.** A `VISION.md` for the product's *why* — standing, product-level, not per-change. Worth it when the repo builds one product with a thesis. Skip it for libraries and tooling.

**Done when** `AGENTS.md` exists, `CLAUDE.md` points at it, and it fits on a page.

---

## Phase 2 — Skills

**Goal.** The unit-of-work prompts, shared by every harness.

**Read** [`skills.md`](skills.md) — the roster, with a source for every entry.

**Delegate.** Run `/bootstrap-agentic-repo` (from `mohganji/skills`). It detects the stack, installs the sources, and offers the setup skills that fit. Don't hand-roll what it already does.

Or install directly:

```bash
npx skills@latest add <owner>/<repo>
```

**Gotcha:** the `--skill=<name>` filter **does not work** — it installs the whole repo regardless. Install, then delete what you don't want.

**Layout.**

- Skills live at `.agents/skills/<name>/SKILL.md` — the harness-neutral home, read directly by Codex and Cursor.
- Claude Code reads `.claude/skills/`, so each entry there is a **symlink**, never a copy: `.claude/skills/<name> -> ../../.agents/skills/<name>`. Commit the symlinks. A copy is a fork you'll forget you made.
- `skills-lock.json` records source and content hash per skill.

**Curate.** The phase people skip and regret. Every skill costs context and adds a second way to do things. Ask whether this repo's work actually hits it. Delete freely — most repos need a third of them.

Two rules worth putting in `AGENTS.md`:

- **Load the skill-authoring skill before writing or editing any skill.** Authoring from memory produces skills that never trigger.
- **Setup skills are one-shot.** Mark them as already-run so agents don't helpfully re-run them.

**Done when** the set is curated, the lockfile matches disk, symlinks are committed, and the index in `AGENTS.md` is true.

---

## Phase 3 — Tracker, labels, domain docs

**Goal.** Agents know where issues live, what the labels mean, where the domain docs are.

**Delegate.** Run `/setup-matt-pocock-skills`. It asks three questions and writes an issue-tracker doc, a triage-labels doc and a domain doc. Don't hand-write these — they exist so the skills have one place to look.

**Nudge it to write them into `.agents-workshop/docs/`** rather than its default `docs/agents/`. Keeps the root lean and puts agent-facing docs with the rest of the agent-facing material.

This is safe because the path is indirect: the consuming skills (`triage`, `to-tickets`, `tdd`, …) never reference the location. They read the `## Agent skills` block the setup skill writes into `AGENTS.md`, which names the files. Point that block at the new path and everything downstream follows.

**Decisions it surfaces.**
- **Tracker** — GitHub Issues, GitLab Issues, local markdown, or Jira/Linear described as prose. Pick where work is *actually* tracked, not where it should be.
- **Labels** — keep the five defaults (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`) unless the tracker already uses other strings.
- **Domain docs** — single-context (`CONTEXT.md` + `docs/adr/`) unless this is a genuine multi-package monorepo.

**If you're doing Phase 8**, add two labels: `agent-review` (implementation done, PR open) and `human-review` (agents converged, a human should look). Document the loop, and the rule that a ticket carries **exactly one** workflow label at a time — replace, never accumulate.

**Tracker gotchas go in `issue-tracker.md`, not here.** The one that has cost the most: Jira's MCP tools read descriptions as pseudo-markdown where smart links appear as placeholder tags, and the write path doesn't convert them back — editing a rich description as markdown destroys every embedded link. Write ADF instead. Record the equivalent trap for your tracker as you hit it.

**Done when** an agent can create, label and transition an issue from those files alone.

---

## Phase 4 — Repo shape

**Goal.** A structure that stays legible as agents add to it.

**Keep the root lean.** Agent config (`.agents/`, `.agents-workshop/`, `.claude/`), the app and service folders, the vision. Everything module-specific — ADRs, `CONTEXT.md`, coding rules, system design — lives in the module folder it describes.

**Split the two docs folders by a testable question.** Root `docs/` is *process*: how we work here. Module `docs/` is *product*: system design, ADRs, domain context.

> Would this doc still be true after the code moves elsewhere? Yes → module docs. No → root docs.

Put that test in `AGENTS.md`. Without it the split erodes in a month.

**Give the agents a place to work.** `.agents-workshop/`, a sibling of `.agents/` — long-term shared memory (`braindump/`), scratch-pads, Remotion videos, research notes, throwaway prototypes, generated reports. Never the source tree, never the repo root.

Read [`workshop.md`](workshop.md) for the layout and the reasoning. The short version: `.agents/` travels *in* and is identical everywhere, so it can be re-synced wholesale; `.agents-workshop/` is generated *here* and is irreplaceable. Nesting one in the other loses both properties.

Create it lazily — a folder per skill that needs one, when it needs one. Add `.agents-workshop/` to every gate's ignore file (Phase 5): a throwaway prototype shouldn't fail CI for its complexity score.

**If this is an incubator:** mirror the migration target's relative paths exactly so imports survive the move. Hard-copy lint configs from the target **verbatim**, at the same relative paths, and change them only by resyncing. Match the target's package manager. State all of it in `AGENTS.md` as a rule — every one of these is something a well-meaning agent will "improve".

**Done when** the shape is written as rules an agent can apply, not a directory tree that happens to exist.

---

## Phase 5 — Gates

**Goal.** One command per gate. Same command at commit and in CI. Blocking.

**Read** [`gates/README.md`](gates/README.md) — it carries the architecture and the hook and CI templates.

**Delegate.** Setup skills exist per gate: `/setup-crap-check`, `/setup-dry`, `/setup-react-doctor`. Run the ones that fit the stack. Each writes a gate script and wires it into both places.

**The architecture matters more than the gate list:**

- **One script per gate**, at `scripts/check-<name>.sh`, holding its own threshold. The hook and CI both call it. Nothing implemented twice.
- **The hook and CI discover gates by glob.** Adding a gate is adding a script. No registration, no drift.
- **Parity is a rule.** Write it in `AGENTS.md`: change a gate, a threshold, or a CI job, and update the hook and CI together. A commit that passes locally must pass CI.
- **Install the hook through the package manager** so a fresh clone is protected without a manual step. A `prepare` script setting `core.hooksPath` does it in one line.
- **Blocking by design.** Warning-only gates are decoration.
- **Ignore files, not exceptions.** Generated and vendored code goes in the gate's ignore file. Never special-case in the script.

**Tests belong here too** — one command, wired in like any other gate.

**Write a `## Commands` section in `AGENTS.md` before tests even exist.** The agent needs one documented way to verify its own work before reporting done. That is the load-bearing half of the whole loop, and several skills and automations assume it. A bug hunt that must prove each finding with a failing test cannot run without a runner.

**Done when** every gate runs green from a clean clone, the hook fires on commit, CI runs the same scripts, and `AGENTS.md` documents the commands and the never-bypass rule.

---

## Phase 6 — Guardrails

**Goal.** The rules that must always hold, enforced *before* the action instead of after.

**Read** [`guardrails/README.md`](guardrails/README.md) first — vocabulary, the three-tier model, the harness capability matrix, and the fail-open evidence that shapes the design.

**Explore.** Which harnesses does this team actually use? Which rules already sit in `AGENTS.md` as prose and get broken anyway?

**Decide.** Promote prose to guardrail when all three hold: it must never be violated, violating it is mechanically detectable, and there's a document behind it. Bypassing the commit gates is the reliable first case — it ships in this folder already.

**Write.** One markdown file per guardrail. Frontmatter per the README's field table, body explaining what a violation looks like and what to do instead. Every guardrail names what it `enforces`. A guardrail with nothing to point at is a rule nobody agreed to.

**Install.**

> Install the guardrails defined in `.agents/guardrails/` for &lt;harness&gt;.

The agent generates the harness config, points it at the adapter, makes it executable, and **reports a coverage table** — per guardrail, enforced at the fast tier or fallen through to `degrades-to`.

**Demand that table.** A silent success is indistinguishable from a fail-open, and fail-open is documented behaviour on more than one harness.

**Verify.** `guardrails/adapters/selftest.sh` runs the roster both ways — the command each guardrail must block, and a near neighbour it must not. Run it after touching any pattern. Add both cases for every new guardrail.

**Done when** the definitions exist, the selftest passes, the coverage table has been reported, and the commit-stage tier still enforces the same rules independently.

---

## Phase 7 — Domain model

**Goal.** Vocabulary and decisions agents can read instead of re-inventing.

Write these in the module's docs folder:

- **`CONTEXT.md`** — the glossary. Every domain term: what it is, what it is not. Include the naming convention: **name things by what they are or who owns them, never by their role in an algorithm.** This is what stops five agents inventing five names for one concept.
- **`docs/adr/NNNN-<slug>.md`** — one decision per file, numbered, never rewritten in place. Cheap to add, and the only durable record of *why*.
- **`INVARIANTS.md`** — numbered `## I<n> — <name>` sections. What must hold, why, and what a violation looks like.

**The block that makes `INVARIANTS.md` earn its keep.** Deliberate designs violate default refactoring heuristics all the time — an append-only ledger that "should" be split, a facade with one implementation. Review agents will flag every one, every time, forever. So put this in `AGENTS.md`:

> **All review and refactoring agents**: before flagging a pattern as a smell, over-abstraction, inconsistency, or dead flexibility, check whether it conforms to a documented ADR or a numbered invariant. If it does, conforming code is correct — do not flag it. To challenge the decision itself, propose an ADR revision as a separate finding, labelled as such. Never "fix" invariant-conforming code inline.

Name the review skills explicitly in that block. Without it, the fleet spends its budget re-litigating settled decisions and you learn to ignore its findings.

**Which invariants become guardrails?** Any that is a grep — a forbidden identifier reaching a public surface, a type imported outside its module. Note the candidates as you write them; graduate them to Phase 6 once the code exists.

**Done when** a new agent reads `CONTEXT.md` and uses the repo's vocabulary correctly without correction.

---

## Phase 8 — Automations

**Goal.** A fleet of cloud agents that moves work through the tracker without a human dispatching each step.

**Read** [`automations/README.md`](automations/README.md). It ships the layer model, trigger vocabulary, and the rules — **no instances**. Automation files are the one thing that never ports between repos: every ticket key, label string, host path and cron in them belongs to the repo that wrote them. A copied automation still pointing at another project's epic will happily file your tickets there.

So you derive them here, from that README's conventions, for this repo's tracker and host.

**The design, in brief.** Definitions are platform-agnostic markdown: one file per agent, frontmatter for trigger/model/tools, body for instructions. Instructions reference *skills* for the actual work. Automations wire **when** and **as whom**; skills define **how**. Three layers:

- **Workers** do one work item per fire — one ticket, or one PR × one review lens.
- **Joiners** fire often and act rarely. Each run checks whether its join condition holds and only then routes. A joiner run that doesn't act posts nothing.
- **Standalone** crons are self-contained single units of work.

**The rules worth copying verbatim. Each was learned by breaking it:**

- **One writer per label edge**, and the writer is the *definition file*, not a trigger registration.
- **Automations never merge.** Their credentials must not carry merge rights. Everything else here is decoration without this one.
- **Every automation signs its output** with a line naming itself. It's how humans and agents tell authors apart when they share an account — and how comment-triggered joiners recognise their own comments and stay silent.
- **The ticket is the ledger.** Every automation comments its activity there, so the ticket alone tells the story. Disable per-automation platform memory, or treat it as non-authoritative.
- **Triggers carry no filters on most platforms.** So every event-triggered automation's first step is a prompt-level bail-out: exit silently unless this item is in scope.
- **Reviewers use independent lenses and never touch labels.** One definition per lens, a joiner decides when they've converged. Never let a reviewer read another reviewer's findings — the independence *is* the value.
- **Keep the flow diagram in sync** in the same commit as any trigger or label-edge change. A stale diagram is worse than none.

**Decide.**
- Which automations this repo needs. Start with triage. Add the implement→review loop only once gates exist.
- Model tier per automation — name a **capability tier**, never a vendor model id, and let the platform map it. Judgment-heavy work gets the strongest tier; joins and checklists don't.
- **A cron backstop?** Recommended: no. Pure event trust, accepting that a dropped event strands its item until someone notices. A sweeper needs a claim protocol and duplicates work. If drops turn out to be common, build a *detector* — a scheduled agent whose deterministic pre-check finds items stuck too long and whose agent only spends tokens on those — not a sweeper that re-does work.

**Deterministic scripts — the decision rule.** Does any step need judgment?

- **No** → it isn't an automation. It's cron or CI. Put it in `scripts/`.
- **Yes, but one step is deterministic** → put the script inside the skill that uses it, and have the automation invoke the skill. A cheap deterministic pre-check that gates the agent ("run X; if clean, stop") lives fine in the automation body.

**Register.** Registration is out-of-repo state on every platform tried so far — dashboard entries, webhook URLs, bearer keys, tracker rules. Mechanical to reproduce from the folder, drift-prone in practice. After any dashboard edit, bring the folder back in sync in the same breath.

**Done when** one automation has fired end to end, left its signature on the ticket, and the ticket tells the story without anyone opening a platform log.

---

## Phase 9 — Environments

**Goal.** A reproducible sandbox the automations boot into.

**Read** [`environments/README.md`](environments/README.md). One folder per environment: `environment.json` (image, install, start), a Dockerfile, an idempotent install script, and a README naming the runtime secrets.

**Source of truth lives in `.agents/environments/`. Platform locations get symlinks, never copies.**

**Verify per platform:** relative paths inside `environment.json` resolve against the folder containing the file, so a manifest written for its symlinked location is only correct when read there. Whether a given builder follows git symlinks is worth checking on the first build. If it doesn't, fall back to copies plus a CI drift check.

**Delegate** provisioning to `/provision-automation-environment`: repo checkout, host CLI auth, dependencies, probes. Run it for a new platform or account, when a probe shows a missing capability, or when the definition changes.

**Expect friction, and record it.** Every platform tried has had at least one undocumented trap: nested group paths rejected by a git-source validator, allowlist network modes blocking the git host, environment variables not reaching setup scripts, cron minutes silently reassigned. None were documented. All cost an afternoon. The findings section is the payoff.

**Done when** a probe in the real environment can clone the repo, authenticate to the host CLI and the tracker, and the required secrets are recorded — not committed.

---

## Phase 10 — Deliberately not built

Absent by choice, not oversight.

- **Measurement.** The factory produces the raw data — label transitions with timestamps, PR events, ledger comments — and computes nothing. Two numbers worth having first: share of items passing agent review without bouncing back, and dwell time per workflow label. One script over the tracker's API.
- **Evals for agent config.** Skills, automations and gate scripts are versioned like code and regression-tested like nothing. A content-hash lockfile tells you *that* an upstream skill changed, never what it broke. The shape: real tasks with expected outcomes, run non-interactively, gated on pass rate, fired on changes to the config paths.
- **The `ask` guardrail tier.** In the vocabulary, unused. It's the one thing the commit stage cannot express — CI can pass or fail, it cannot pause for a named approver. Reach for it when protected-path sign-off becomes real.

---

## Verification checklist

The factory works when all of these are true:

- [ ] A fresh clone installs and the commit hook is active without a manual step.
- [ ] Every gate runs green, from one command each, and blocks on failure.
- [ ] `guardrails/adapters/selftest.sh` passes, and a coverage table was reported per harness.
- [ ] An agent starting cold reads `AGENTS.md` and uses the repo's vocabulary, gates and structure rules without correction.
- [ ] Creating an issue puts it in the right project with the right label, and triage picks it up.
- [ ] One work item has gone tracker → branch → PR → review → human merge → done, with the ticket telling the whole story.
- [ ] Every `enforces:` pointer in `guardrails/` resolves to a real section in a real file.
- [ ] No inherited instance data anywhere in `.agents/` — no other repo's ticket keys, epic ids, or host paths.

## Keeping this true

The scaffold is only as good as its last update. When a phase's reality changes — a new gate, a retired layer, a platform finding that changes an install step — update this file in the same commit.

It is the one document whose whole purpose is to be read by someone who wasn't there.
