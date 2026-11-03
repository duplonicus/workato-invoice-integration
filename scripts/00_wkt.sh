#!/usr/bin/env bash
# wkt: wk (Workato Labs CLI) wrapper for a file-store auth profile.
# File-store profiles can't be the global active profile, so every call needs
# --profile <name> --store-type file. This adds them; the profile comes from WK_PROFILE.
#
# Alias it as `wkt` (add both lines to ~/.bashrc, then `source ~/.bashrc`):
#   export WK_PROFILE=trial-<workspace>-dev        # see: wk auth list --store-type file
#   alias wkt='/path/to/workato-invoice-integration/scripts/00_wkt.sh'
#
# Run it from the wk project dir (workspace/): wk finds a file-store profile only in
# the folder it lives in.
#   cd workspace && wkt status      # or, without the alias: ../scripts/00_wkt.sh status
set -euo pipefail
: "${WK_PROFILE:?set WK_PROFILE to your wk auth profile name (see: wk auth list --store-type file)}"
exec wk "$@" --profile "$WK_PROFILE" --store-type file
