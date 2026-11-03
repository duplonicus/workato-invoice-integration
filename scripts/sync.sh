#!/usr/bin/env bash
# Keep local recipe JSON and the workspace in sync (run inside the wk project dir).
#   ./sync.sh pull   # web-app edits -> local JSON (what produced ../recipes/*.json)
#   ./sync.sh push   # local JSON edits -> workspace (makes real changes: sandbox only)
#   ./sync.sh diff   # what would change
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
case "${1:-status}" in
  pull) "$here/wk.sh" pull && "$here/wk.sh" status ;;
  push) "$here/wk.sh" diff && read -rp "Push these changes? [y/N] " a && [[ $a == y ]] && "$here/wk.sh" push ;;
  diff) "$here/wk.sh" diff ;;
  status) "$here/wk.sh" status ;;
  *) echo "usage: sync.sh pull|push|diff|status" >&2; exit 2 ;;
esac
