# default

The environment the automation fleet runs in.

Debian (`node:22-bookworm`) with node, npm, python3, git and curl from the base image, plus `gh` and `glab` baked in. The install step sets the git identity, verifies host auth, and installs dependencies.

Host detection is automatic from `origin`. Override with `HOST=github|gitlab`.

## Files

| File | What |
| --- | --- |
| `environment.json` | manifest — see [`../README.md`](../README.md) for the path-resolution caveat |
| `Dockerfile` | tooling image; never COPYs the project |
| `install.sh` | idempotent install step, run in the workspace root after checkout |

## Runtime secrets

From the platform's secrets store, injected as environment variables. Never committed, never printed.

| Variable | Host | Required | What |
| --- | --- | --- | --- |
| `GH_TOKEN` | GitHub | yes | Fine-grained PAT: `contents:write`, `pull-requests:write`, `issues:write`. **No merge rights.** |
| `GITLAB_TOKEN` | GitLab | yes | Project access token, **Developer** role, scopes `api, read_repository, write_repository`. |
| `GITLAB_HOST` | GitLab | no | Defaults to `gitlab.com`. |
| `GIT_AUTHOR` | both | no | Git identity for automation commits, `"Name <email>"`. |

**Developer role, not Maintainer. No merge rights on the PAT.**

Automations never merge — that's the load-bearing rule of the whole fleet, and the credential is where it's actually enforced. A prompt that says "don't merge" is a suggestion. A token that can't merge is a fact.

## Symlink it into place

```bash
mkdir -p .cursor
ln -s ../.agents/environments/default/environment.json .cursor/environment.json
ln -s ../.agents/environments/default/Dockerfile       .cursor/Dockerfile
```

Cursor auto-detects the environment from `.cursor/environment.json` once the repo is selected.

Whether its builder follows the symlinks is unverified — see [`../README.md`](../README.md) for the check and the fallback.
