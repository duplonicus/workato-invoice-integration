#!/usr/bin/env bash
# wk (Workato Labs CLI) wrapper for a file-store auth profile.
# File-store profiles can't be the global active profile, so every call needs
# --profile <name> --store-type file. Set WK_PROFILE once and use this instead of wk.
#   export WK_PROFILE=trial-<workspace>-dev
#   ./scripts/wk.sh pull
set -euo pipefail
: "${WK_PROFILE:?set WK_PROFILE to your wk auth profile name (see: wk auth list --store-type file)}"
exec wk "$@" --profile "$WK_PROFILE" --store-type file
