#!/usr/bin/env bash
# PreToolUse on Bash: block git pushes that target main.
COMMAND=$(jq -r '.tool_input.command // empty')
IS_PUSH='git[[:space:]]+push'
TO_MAIN='(^|[[:space:]:])main([[:space:]]|$)' # "origin main", "HEAD:main", not "wh-2-main-fix"
[[ "$COMMAND" =~ $IS_PUSH ]] || exit 0
# shortcut: matches "main" anywhere in a command that pushes, so "git log main && git push x" is blocked too; parse refspecs if that bites.
if [[ "$COMMAND" =~ $TO_MAIN ]] || [ "$(git branch --show-current 2>/dev/null)" = main ]; then
  echo "Direct push to main is forbidden. Push a wh-<x>-<y> branch and open a PR." >&2
  exit 2 # 2 blocks the call; exit 1 would only warn and let the push run
fi
exit 0
