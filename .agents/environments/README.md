# Environments

The sandbox the automations boot into.

One folder per logical environment, holding everything a platform needs to build and boot it:

- `environment.json` — the manifest. We adopt [Cursor's `environment.json` schema](https://www.cursor.com/schemas/environment.schema.json) as the platform-neutral standard: image (`build.dockerfile` + `build.context`, or `snapshot`), `install`, `start`, `terminals`, `ports`.
- `Dockerfile` — the image. Tooling only.
- `install.sh` — the idempotent install step the manifest points at.
- `README.md` — what it's for, and which runtime secrets it needs.

[`default/`](default/) is a working starting point: Debian, node, python3, `gh` and `glab`, with auth verified at install time.

## Source of truth lives here. Platform locations get symlinks.

Cursor reads `.cursor/environment.json`. That path is a symlink into this folder, never a copy. A new platform that wants the manifest elsewhere gets another symlink, not a fork.

```bash
ln -s ../.agents/environments/default/environment.json .cursor/environment.json
ln -s ../.agents/environments/default/Dockerfile       .cursor/Dockerfile
```

## The path-resolution caveat

`build.dockerfile` and `build.context` resolve **relative to the folder containing the file** — and the manifest is written for its *resolved* location. `"context": ".."` means the repo root only when the file is read at `.cursor/environment.json`.

**Whether a given builder follows git symlinks is unverified. Check it on the first build.**

If it doesn't, fall back to copies in the platform folder plus a CI drift check that fails when they diverge. Never copies alone — that's a fork with extra steps.

## Provisioning

Delegate to `/provision-automation-environment`: repo checkout, host CLI auth, dependencies, probes.

Run it when setting up a new platform or account, when a probe shows a missing capability, or when the definition changes.

## Never commit secrets

The manifest names which secrets it needs. The values live in the platform's secrets store, injected as environment variables.

Install scripts verify a secret works. They never print it.

## Expect friction, and write it down

Every platform tried has had at least one undocumented trap:

- Git-source validators rejecting nested group paths.
- Allowlist network modes blocking the git host outright.
- Environment-dialog variables not reaching setup scripts.
- Cron minutes silently reassigned.

None were documented. All cost an afternoon. Record what you hit in [`../automations/README.md`](../automations/README.md) § Platform findings — that section is the payoff.
