#!/usr/bin/env bash
# Keep local recipe JSON and the workspace in sync (run inside the wk project dir).
#   ./02_sync.sh pull   # web-app edits -> local JSON (what produced ../recipes/*.json)
#   ./02_sync.sh push   # local JSON edits -> workspace (makes real changes: sandbox only)
#   ./02_sync.sh diff   # what would change
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
case "${1:-status}" in
  pull) "$here/wkt" pull && "$here/wkt" status ;;
  push) "$here/wkt" diff && read -rp "Push these changes? [y/N] " a && [[ $a == y ]] && "$here/wkt" push ;;
  diff) "$here/wkt" diff ;;
  status) "$here/wkt" status ;;
  *) echo "usage: 02_sync.sh pull|push|diff|status" >&2; exit 2 ;;
esac
