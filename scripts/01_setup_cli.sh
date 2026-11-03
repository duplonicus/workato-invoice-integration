#!/usr/bin/env bash
# One-time CLI setup against a Workato Developer Sandbox (app.trial.workato.com).
# Prereq (web app, once): Workspace admin > API clients
#   1. Client roles > Add client role (Projects: Projects & folders, Connections, Recipes,
#      Recipe Versions, Jobs, Test Cases, Recipe lifecycle management, Export manifests;
#      Admin: the endpoint GET /api/users/me, which wk calls to validate the token).
#   2. Create API client with that role, project access = your project. Copy the token (shown once).
# Install wk: https://github.com/workato-devs/wk (brew install workato-devs/tap/wk, or go install).
set -euo pipefail
project="${1:?usage: 01_setup_cli.sh <workato-project-name> [dir]}"
dir="${2:-workspace}"
mkdir -p "$dir" && cd "$dir"

# Interactive: paste the token at the prompt (never on the command line), pick region "trial".
# File store writes profiles.env here: it holds the token, so it is gitignored.
wk auth login --store-type file

wk auth list --store-type file
read -rp "Profile name to use: " WK_PROFILE
export WK_PROFILE

# wk init asks for a project name and the auth profile; --project links the Workato project folder.
wk init --project "$project"
wk pull --profile "$WK_PROFILE" --store-type file
wk status --profile "$WK_PROFILE" --store-type file
echo "Done. Note: pull fails with 'Package archive is not ready' while the project is still empty."
