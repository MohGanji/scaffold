#!/usr/bin/env bash
# Install step for the automation environment. See README.md.
# Runs in the workspace root after the platform checks out the repo.
#
# IDEMPOTENT by requirement: the platform may run this repeatedly, on partially
# cached state. Every step must be safe to re-run.
#
# Runtime secrets come from the platform's secrets store as env vars. This
# script verifies them and never prints them.
#
#   GH_TOKEN     — GitHub. Fine-grained PAT, contents:write, pull-requests:write,
#                  issues:write. NO merge rights — automations never merge.
#   GITLAB_TOKEN — GitLab. Project access token, Developer role,
#                  scopes: api, read_repository, write_repository.
#
# Set whichever your host needs. HOST=github|gitlab|auto (default: auto).
set -euo pipefail

HOST="${HOST:-auto}"
if [ "$HOST" = "auto" ]; then
  remote="$(git remote get-url origin 2>/dev/null || echo '')"
  case "$remote" in
    *github.com*) HOST=github ;;
    *gitlab*)     HOST=gitlab ;;
    *)            HOST=none ;;
  esac
fi
echo "── host: ${HOST} ──"

echo "── git identity ──"
GIT_AUTHOR="${GIT_AUTHOR:-automations <automations@users.noreply.github.com>}"
git config --global user.name  "$(echo "$GIT_AUTHOR" | sed 's/ <.*//')"
git config --global user.email "$(echo "$GIT_AUTHOR" | sed 's/.*<\(.*\)>/\1/')"

case "$HOST" in
  github)
    echo "── gh auth ──"
    if [ -z "${GH_TOKEN:-}" ]; then
      echo "ERROR: GH_TOKEN is not set."
      echo "Add it as a runtime secret — fine-grained PAT with contents:write,"
      echo "pull-requests:write, issues:write, and NO merge rights (see README.md)."
      exit 1
    fi
    # gh reads GH_TOKEN from the environment natively — no login, nothing on disk.
    if ! gh auth status >/dev/null 2>&1; then
      echo "ERROR: 'gh auth status' failed — GH_TOKEN is set but rejected."
      echo "Check its expiry and scopes. Never echo the token."
      exit 1
    fi
    echo "gh authenticated"
    ;;
  gitlab)
    echo "── glab auth ──"
    if [ -z "${GITLAB_TOKEN:-}" ]; then
      echo "ERROR: GITLAB_TOKEN is not set."
      echo "Add it as a runtime secret — project access token, Developer role,"
      echo "scopes api, read_repository, write_repository (see README.md)."
      exit 1
    fi
    export GITLAB_HOST="${GITLAB_HOST:-gitlab.com}"
    if ! glab auth status >/dev/null 2>&1; then
      echo "ERROR: 'glab auth status' failed against ${GITLAB_HOST} — token rejected."
      echo "Check its expiry and scopes. Never echo the token."
      exit 1
    fi
    echo "glab authenticated against ${GITLAB_HOST}"
    ;;
  *)
    echo "WARN: no recognised git host on origin — skipping host CLI auth."
    ;;
esac

echo "── dependencies ──"
if [ -f package-lock.json ]; then
  npm ci --no-audit --no-fund
else
  echo "no package-lock.json in $(pwd) — skipping npm ci"
fi

echo "── install done ──"
