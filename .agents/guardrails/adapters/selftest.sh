#!/usr/bin/env bash
# Exercises every guardrail through the Claude Code adapter, both ways: the
# command it must block, and a near neighbour it must not. Run after touching
# any definition, any regex, or the adapter itself.
#
#   .agents/guardrails/adapters/selftest.sh
set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
adapter="$here/claude.sh"
failures=0

payload() { # $1 = command string, $2 = tool name (default Bash)
  if command -v jq >/dev/null 2>&1; then
    jq -n --arg c "$1" --arg t "${2:-Bash}" '{tool_name: $t, tool_input: {command: $c}}'
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c 'import json,sys; print(json.dumps({"tool_name": sys.argv[2], "tool_input": {"command": sys.argv[1]}}))' "$1" "${2:-Bash}"
  else
    echo "selftest: needs jq or python3 to build payloads" >&2
    exit 1
  fi
}

check() { # $1 = expected exit code, $2 = command, $3 = tool name (optional)
  local expected="$1" cmd="$2" tool="${3:-Bash}" out rc
  out="$(payload "$cmd" "$tool" | "$adapter" 2>&1)"
  rc=$?
  if [ "$rc" = "$expected" ]; then
    printf '  ok    exit=%s  %s\n' "$rc" "$cmd"
  else
    printf '  FAIL  exit=%s want=%s  %s\n' "$rc" "$expected" "$cmd"
    [ -n "$out" ] && printf '        %s\n' "$out"
    failures=$((failures + 1))
  fi
}

echo "no-verify-is-not-an-option — must block"
check 2 'git commit --no-verify -m "wip"'
check 2 'git commit -n -m "wip"'
check 2 'git commit -am "wip" --no-verify'

echo "no-verify-is-not-an-option — must allow"
check 0 'git commit -m "a normal message"'
check 0 'git commit --amend --no-edit'
check 0 'git commit -am "another normal message"'

echo "non-shell tools are not this adapter's business"
check 0 'anything at all' 'Edit'

echo
if [ "$failures" -eq 0 ]; then
  echo "all guardrail cases passed"
else
  echo "$failures case(s) failed"
  exit 1
fi
