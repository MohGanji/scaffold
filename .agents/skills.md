# Skills

Scaffold ships **no skill files**. It ships this list.

Skills are borrowed from their sources at setup time. Vendoring someone else's skill into your repo buys you a copy that goes stale silently — the lockfile tells you *that* it changed upstream, never what it broke. So the factory points at sources and installs them fresh.

Install everything the fast way:

```bash
npx skills@latest add mohganji/skills
```

Then run `/bootstrap-agentic-repo`. It detects the stack, installs the rest, and offers the setup skills that fit.

**Remotion is the case that proves the curate rule.** `remotion-dev/remotion` ships ~68 skills, and most of them are for contributing *to* Remotion — `add-bug`, `gh-stack`, `fix-dependabot`, `update-stars`. Keep the `remotion-*` ones (`remotion-create`, `remotion-best-practices`, `remotion-render`, `remotion-studio`, `remotion-captions`, `remotion-docs`) and delete the rest. Installing all 68 buys you a context bill and sixty ways to file a bug against someone else's repo.

**Gotcha:** `--skill=<name>` **does not filter** — it installs the whole repo regardless. Install, then delete what you don't want, then prune `skills-lock.json`.

## Sources

| Source | Install |
| --- | --- |
| [`mohganji/skills`](https://github.com/MohGanji/skills) | `npx skills@latest add mohganji/skills` |
| [`mattpocock/skills`](https://github.com/mattpocock/skills) | `npx skills@latest add mattpocock/skills` |
| [`millionco/react-doctor`](https://github.com/millionco/react-doctor) | `npx skills@latest add millionco/react-doctor` |
| [`ericzakariasson/scandinavian-design`](https://github.com/ericzakariasson/scandinavian-design) | `npx skills@latest add ericzakariasson/scandinavian-design` |
| [`emilkowalski/skills`](https://github.com/emilkowalski/skills) | `npx skills@latest add emilkowalski/skills` |
| [`remotion-dev/remotion`](https://github.com/remotion-dev/remotion) | `npx skills@latest add remotion-dev/remotion` — **curate hard**, see below |
| [`199-biotechnologies/motion-dev-animations-skill`](https://github.com/199-biotechnologies/motion-dev-animations-skill) | `npx skills@latest add 199-biotechnologies/motion-dev-animations-skill` |
| [`cursor/plugins`](https://github.com/cursor/plugins) — `cursor-team-kit` | [`thermo-nuclear-code-quality-review`](https://github.com/cursor/plugins/blob/main/cursor-team-kit/skills/thermo-nuclear-code-quality-review/SKILL.md). `find-critical-bugs` started as a Cursor automation template — the skill adaptation installs from `mohganji/skills`. |

## Roster

Grouped by what they do in the factory. Install what your repo's work actually hits — most repos need a third of this.

### Setup — one-shot

Run once, then mark as already-run in `AGENTS.md` so agents don't helpfully re-run them.

| Skill | Source | What it does |
| --- | --- | --- |
| `bootstrap-agentic-repo` | mohganji | Detects the stack, installs every skill source, walks the setup skills |
| `setup-matt-pocock-skills` | mattpocock | Writes `docs/agents/` — tracker, labels, domain docs (Phase 3) |
| `setup-crap-check` | mohganji | CRAP-score gate, hook + CI |
| `setup-dry` | mohganji | Structural-duplication gate, hook + CI |
| `setup-react-doctor` | mohganji | React quality gate, hook + CI |
| `provision-automation-environment` | mohganji | Cloud environment for the automation fleet (Phase 9) |

### Plan

| Skill | Source | What it does |
| --- | --- | --- |
| `to-spec` | mattpocock | Context → spec. Every new ticket starts here |
| `to-tickets` | mattpocock | Spec → tickets |
| `triage` | mattpocock | Issue state machine to an agent-ready brief |
| `priority-score` | mohganji | Rank a backlog by `(breadth × depth) / cost` |
| `domain-modeling` | mattpocock | Ubiquitous language and ADRs (Phase 7) |
| `grilling` | mattpocock | Stress-test a plan before building it |
| `grill-with-docs` | mattpocock | Same, grounded in real docs |
| `research` | mattpocock | Investigate against primary sources, write it down |

### Build

| Skill | Source | What it does |
| --- | --- | --- |
| `implement` | mattpocock | Work a ticket to a PR |
| `tdd` | mattpocock | Red-green-refactor |
| `prototype` | mattpocock | Throwaway build to answer a design question |
| `codebase-design` | mattpocock | Deep modules, seams, testability |
| `wayfinder` | mattpocock | Navigate an unfamiliar codebase |
| `orchestrate` | mohganji | Run the session as a delegator over long-lived subagents |
| `experiment` | mohganji | Build every candidate behind a variant switcher, pick by feel |

### Review

The lenses the automation fleet runs. Independent by design — never let one read another's findings.

| Skill | Source | Lens |
| --- | --- | --- |
| `find-critical-bugs` | cursor | Correctness. Data loss, crashes, races, silent corruption — each proven by a failing test |
| `thermo-nuclear-code-quality-review` | cursor | Structure and maintainability |
| `refactoring-guru` | mohganji | Smells → prescribed treatments, refactoring.guru methodology |
| `matt-code-review` | mattpocock | Standards and spec conformance |
| `improve-codebase-architecture` | mattpocock | Architecture-level findings |
| `cut-the-crap` | mohganji | CRAP score — complexity against coverage |
| `dry` | mohganji | Structural duplication via AST fingerprinting |
| `react-doctor` / `improve-react` | millionco | React anti-patterns and re-render cost |
| `no-broken-window` | mohganji | One violation shouldn't erode the standard |

### Design

| Skill | Source | What it does |
| --- | --- | --- |
| `design-deliberately` | mohganji | Intentional minimalism — every element earns its place |
| `apple-design` | emilkowalski | Apple's motion, gesture, material and typography, for the web |
| `scandinavian-design` | ericzakariasson | Scandinavian visual system, with a scoring harness |

### Motion & video

Reach for these when the deliverable moves — an interface transition, a launch film, a feature demo.

| Skill | Source | What it does |
| --- | --- | --- |
| `animate` | emilkowalski | Build an animation that feels right, not just one that runs |
| `improve-animations` | emilkowalski | Fix timing, easing and interruption on animations that already exist |
| `review-animations` | emilkowalski | Critique motion the way a design engineer would |
| `find-animation-opportunities` | emilkowalski | Spot the places motion would earn its keep |
| `animation-vocabulary` | emilkowalski | Shared language for describing motion precisely |
| `motion-dev-animations` | [199-biotechnologies](https://github.com/199-biotechnologies/motion-dev-animations-skill) | Motion.dev — 120fps, spring physics, scroll and gesture |
| `remotion-create` · `remotion-best-practices` · `remotion-render` · `remotion-studio` | remotion | Video as React. See the curate warning above |

Remotion videos live in [`.agents-workshop/videos/`](workshop.md), one project per video — not at the repo root.

### Meta

| Skill | Source | What it does |
| --- | --- | --- |
| `braindump` | mohganji | Long-term memory. One dense fact per line, appended to a topic file, grepped back next session |
| `writing-great-skills` | mattpocock | **Load this before writing or editing any skill.** Authoring from memory produces skills that never trigger |

## Layout

- Skills live at `.agents/skills/<name>/SKILL.md` — harness-neutral, read directly by Codex and Cursor.
- Claude Code reads `.claude/skills/`, so each entry there is a **symlink**: `.claude/skills/<name> -> ../../.agents/skills/<name>`. Commit the symlinks. A copy is a fork you'll forget you made.
- `skills-lock.json` records source and content hash per skill.

`.agents/skills/` is gitignored in this repo. It is a *destination*, not content — the whole point of the borrow model.

## Adding one

A skill that doesn't exist yet goes to a source repo first, then into this list. Never straight into a project.

Write it with `writing-great-skills` loaded. Publish it. Then add the row.
