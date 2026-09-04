# The workshop

Agents need a place to work.

Long-term shared memory, scratch-pads, Remotion videos, research notes, throwaway prototypes, generated reports. None of it is your product, all of it is worth keeping, and none of it belongs in your source tree.

```
your-repo/
├── .agents/            the factory — how the agents work
├── .agents-workshop/   where the agents work — braindump, scratch-pads, videos
├── src/
└── package.json
```

## Why a sibling, not a subfolder

`.agents/` and `.agents-workshop/` differ in the one way that matters: **config versus output.**

`.agents/` is configuration — how the factory works. Some of it arrives from scaffold, some you write yourself (your guardrails, your automations, your environments). All of it is small, hand-authored text worth reading a diff of.

`.agents-workshop/` is what the factory produced. Generated, often large, and meaningless to diff — nobody reviews a rendered MP4 line by line.

Nest them and you lose both properties. `cp -R scaffold/.agents your-repo/` starts dragging one repo's artifacts into another — the same failure mode that makes automations unportable.

**The payoff is upgrades.** Point an agent back at scaffold a year from now and ask it to update your factory, and `.agents/` is the entire diff surface — config against config. Every difference is a real decision: upstream added a guardrail, or you wrote an automation, or both touched the same convention.

Nest the workshop inside it and that diff fills with your research notes, your rendered videos and last quarter's prototypes, and the one useful signal drowns.

The `.agents-` prefix keeps the pairing visible and sorts them adjacent. The separation stays real.

**Why not `workspace`?** npm workspaces, VS Code workspaces, Cursor workspaces. The word already means "tooling config" to every tool that might read it.

## What goes in

| Folder | Holds | Written by |
| --- | --- | --- |
| `docs/` | Agent-facing project docs — issue tracker, triage labels, domain layout | `setup-matt-pocock-skills` |
| `braindump/` | Long-term memory, one dense fact per line, grouped by topic — decisions and their reasons, gotchas, approaches already rejected | `braindump` |
| `scratch/` | Working files for a task in flight. Safe to delete at any time. | any agent |
| `videos/` | One Remotion project per video. Launch films, feature demos. | `remotion-*`, `setup-remotion` |
| `research/` | Findings against primary sources, kept as markdown | `research` |
| `prototypes/` | Throwaway builds answering one design question | `prototype`, `experiment` |
| `reports/` | Architecture dashboards, review output, generated HTML | `improve-codebase-architecture`, review lenses |
| `inspirations/` | Reference material you drop in — videos, screenshots, styles | you |

Add folders as skills need them. The rule is the test below, not this table.

**`braindump/` is the one worth being deliberate about.** It's shared — every agent reads it, any agent may append to it. That makes it the cheapest way to stop the fleet re-deriving the same conclusion every week, and the fastest way to poison it if something wrong gets written down and never re-checked. Every line is dated, stands on its own, and gets deleted when it stops being true. A memory nobody prunes becomes a memory nobody trusts.

## The test

> Would you ship this to a user, or does the build depend on it?

**Yes** → your source tree. It's product.
**No, but you want to keep it** → `.agents-workshop/`.
**No, and it's regenerable** → `.agents-workshop/`, gitignored.

Research notes are worth committing. A 200MB rendered MP4 is not.

## Videos

One project per video, each standalone with its own `package.json`:

```
.agents-workshop/
├── videos/
│   ├── launch-film/          npx create-video@latest --yes --blank launch-film
│   ├── feature-demos/
│   └── shared/               design kit every composition imports from
└── inspirations/             reference material
```

`shared/` holds colors, fonts, layouts and brand components matching the product's design system. Every composition imports from it unless the video deliberately breaks style. It fills up as videos get made — don't try to design it upfront.

Rendered output is gitignored. The composition is source; the MP4 is a build artifact.

## Gitignore

Commit the work, ignore the renders and the installs:

```gitignore
.agents-workshop/**/node_modules/
.agents-workshop/**/out/
.agents-workshop/videos/**/*.mp4
.agents-workshop/reports/
.agents-workshop/scratch/
```

Adjust per folder. The default is **commit it** — an agent's research note is worth more in six months than it is today, and it costs kilobytes. `braindump/` in particular is worthless uncommitted: shared means shared with the next clone, not just the next session.

## Gates do not run here

Quality gates scope to your source tree. A throwaway prototype should not fail CI for its CRAP score, and a Remotion composition is not held to the product's lint rules.

Add `.agents-workshop/` to each gate's ignore file. That's the ignore-file rule from [`gates/README.md`](gates/README.md), applied here — never a special case inside the script.

The exception is anything you later promote out of the workshop into the product. At that point it's product, and the gates apply.
