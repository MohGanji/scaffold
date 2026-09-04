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

`.agents/` is config — hand-authored text worth reading a diff of. The workshop is output — generated, often large, meaningless to diff.

Keeping them apart is what makes upgrades work: point an agent back at scaffold later and `.agents/` is the whole comparison surface, instead of a diff drowning in rendered videos and last quarter's prototypes.

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

Add folders as skills need them.

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

## Gates

Add `.agents-workshop/` to each gate's ignore file ([`gates/README.md`](gates/README.md)) — a throwaway prototype shouldn't fail CI for its complexity score.
