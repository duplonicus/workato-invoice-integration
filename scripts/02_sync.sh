#!/usr/bin/env bash
# Keep local recipe JSON and the workspace in sync (run inside the wk project dir).
#   ../scripts/02_sync.sh pull   # web-app edits -> local JSON (what produced ../recipes/*.json)
#   ../scripts/02_sync.sh push   # local JSON edits -> workspace (makes real changes: sandbox only)
#   ../scripts/02_sync.sh diff   # what would change
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
case "${1:-status}" in
  pull) "$here/00_wkt.sh" pull && "$here/00_wkt.sh" status ;;
  push) "$here/00_wkt.sh" diff && read -rp "Push these changes? [y/N] " a && [[ $a == y ]] && "$here/00_wkt.sh" push ;;
  diff) "$here/00_wkt.sh" diff ;;
  status) "$here/00_wkt.sh" status ;;
  *) echo "usage: 02_sync.sh pull|push|diff|status" >&2; exit 2 ;;
esac
