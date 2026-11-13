#!/usr/bin/env bash
# PostToolUse on Write|Edit: format the touched file with Prettier.
FILE_PATH=$(jq -r '.tool_input.file_path // empty')
[ -f "$FILE_PATH" ] || exit 0
# Prettier lives in app/ and api/, not the root; run from the file's dir and never download it.
cd "$(dirname "$FILE_PATH")" && npx --no-install prettier --write "$FILE_PATH" \
  2>/dev/null || true
exit 0
