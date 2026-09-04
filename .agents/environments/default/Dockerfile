# Tooling image for the automation fleet. See README.md.
#
# Paths are written for this file's RESOLVED location (e.g. .cursor/Dockerfile,
# symlinked from here) — see ../README.md § The path-resolution caveat.
#
# Do NOT COPY the project. The platform manages the workspace and checks out the
# correct commit. This image provides tooling and nothing else.
#
# node:22-bookworm = Debian 12 with node, npm, git, curl and python3.
FROM node:22-bookworm

# Fail the build loudly if a base-image change drops a tool the gates rely on.
RUN command -v git && command -v curl && command -v python3

# gh — GitHub CLI, from the official apt repo.
RUN set -eux; \
    mkdir -p -m 755 /etc/apt/keyrings; \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      -o /etc/apt/keyrings/githubcli-archive-keyring.gpg; \
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends gh; \
    rm -rf /var/lib/apt/lists/*; \
    gh --version

# glab — GitLab CLI. Baked in at build time so the flaky release download
# happens in a cached layer, not per session. Asset naming has changed across
# releases, so try both known shapes.
RUN set -eux; \
    VER="$(curl -fsSL 'https://gitlab.com/api/v4/projects/gitlab-org%2Fcli/releases/permalink/latest' | sed -E 's/.*"tag_name":"v([^"]+)".*/\1/')"; \
    curl -fsSL -o /tmp/glab.tar.gz "https://gitlab.com/gitlab-org/cli/-/releases/v${VER}/downloads/glab_${VER}_linux_amd64.tar.gz" || \
    curl -fsSL -o /tmp/glab.tar.gz "https://gitlab.com/gitlab-org/cli/-/releases/v${VER}/downloads/glab_${VER}_Linux_x86_64.tar.gz"; \
    mkdir -p /tmp/glab-extract; \
    tar -xzf /tmp/glab.tar.gz -C /tmp/glab-extract; \
    install "$(find /tmp/glab-extract -type f -name glab | head -1)" /usr/local/bin/glab; \
    rm -rf /tmp/glab.tar.gz /tmp/glab-extract; \
    glab --version
