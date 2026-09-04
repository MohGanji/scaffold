#!/usr/bin/env bash
# Claude Code PreToolUse adapter for the guardrails in .agents/guardrails/.
# Contract: ../README.md § Adapter contract
#
# Data-driven on purpose: this script reads every guardrail definition at call
# time, so adding a guardrail is adding a markdown file — no codegen, no drift.
#
# The deny path is `exit 2` + stderr, which is the ONLY Claude Code path that
# blocks unconditionally. A JSON `permissionDecision` fails OPEN when the output
# does not validate, and a fail-open guardrail is worse than none because it
# reads as coverage. See ../README.md § Three tiers.
set -uo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
payload="$(cat)"

# Read one string field from the payload. Returns 1 only when no JSON parser
# exists at all, which the caller must report rather than silently allow.
json_get() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$payload" | jq -r --arg p "$1" 'getpath($p | split(".")) // empty' 2>/dev/null
  elif command -v python3 >/dev/null 2>&1; then
    printf '%s' "$payload" | python3 -c '
import json, sys
try:
    node = json.load(sys.stdin)
except Exception:
    sys.exit(0)
for key in sys.argv[1].split("."):
    if not isinstance(node, dict):
        sys.exit(0)
    node = node.get(key)
    if node is None:
        sys.exit(0)
print(node if isinstance(node, str) else "")
' "$1" 2>/dev/null
  else
    return 1
  fi
}

# One frontmatter field from a guardrail definition.
field() {
  awk -v key="$2" '
    NR == 1 && $0 == "---" { in_fm = 1; next }
    in_fm && $0 == "---"   { exit }
    in_fm {
      i = index($0, ":")
      if (i > 0 && substr($0, 1, i - 1) == key) {
        v = substr($0, i + 1)
        sub(/^[ \t]+/, "", v)
        print v
        exit
      }
    }
  ' "$1"
}

unquote() { sed -e "s/^'//" -e "s/'\$//" -e 's/^"//' -e 's/"$//'; }

if ! tool="$(json_get tool_name)"; then
  echo "guardrails: neither jq nor python3 found — guardrails are NOT enforced for this call." >&2
  echo "guardrails: install jq, or rely on the commit-stage tier (see .agents/guardrails/README.md)." >&2
  exit 0
fi

[ "$tool" = "Bash" ] || exit 0
cmd="$(json_get tool_input.command)"
[ -n "$cmd" ] || exit 0

for gr in "$dir"/*.md; do
  base="$(basename "$gr")"
  [ "$base" = "README.md" ] && continue

  [ "$(field "$gr" event | unquote)" = "before-shell" ] || continue
  [ "$(field "$gr" action | unquote)" = "deny" ] || continue

  match="$(field "$gr" match | unquote)"
  [ -n "$match" ] || continue
  printf '%s' "$cmd" | grep -Eqi -- "$match" || continue

  when="$(field "$gr" deny-when | unquote)"
  if [ -n "$when" ]; then
    printf '%s' "$cmd" | grep -Eqi -- "$when" || continue
  fi

  printf 'Blocked by guardrail: %s\n\n%s\n\nDefinition: .agents/guardrails/%s\n' \
    "${base%.md}" "$(field "$gr" message | unquote)" "$base" >&2
  exit 2
done

exit 0
