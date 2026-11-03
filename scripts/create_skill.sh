#!/usr/bin/env bash
# Create the post_invoice skill from code (what was done in the web app with Create > Skill).
#   1. import the skill recipe JSON (Start workflow trigger -> HTTP POST -> Return response)
#   2. start the recipe (MCP tools stay "Inactive" until the skill recipe is running)
#   3. register the recipe as a skill
# Uses the wk CLI via ./wk.sh (needs WK_PROFILE):
#   wk recipes import <path> --folder <id> | wk recipes start <id> | wk agentic skills create --recipe-id <id>
# A skill can't be deleted through the API (only in the web app), so run this only where you mean to keep it.
# Writes scripts/.recipe_id and scripts/.skill_id (both gitignored) for create_mcp_server.sh.
# Usage: ./create_skill.sh <folder-id> [recipe.json]   (find the folder id: ./wk.sh folders list --projects)
# Needs: wk, jq.
# Run it from the wk project dir (workspace/): wk finds a file-store profile only in the current folder.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
folder="${1:?usage: create_skill.sh <folder-id> [recipe.json]}"
recipe="${2:-$here/../recipes/post_invoice.recipe.json}"

echo "1/3 importing $recipe into folder $folder"
out=$("$here/wk.sh" recipes import "$recipe" --folder "$folder" --json)
recipe_id=$(jq -r '.id // .recipe.id // empty' <<<"$out")
: "${recipe_id:?import returned no recipe id: $out}"
echo "$recipe_id" > "$here/.recipe_id"
echo "    recipe id: $recipe_id (saved to scripts/.recipe_id)"

echo "2/3 starting recipe $recipe_id"
"$here/wk.sh" recipes start "$recipe_id"

echo "3/3 creating skill from recipe $recipe_id"
skill=$("$here/wk.sh" agentic skills create --recipe-id "$recipe_id" --json)
skill_id=$(jq -r '.id // empty' <<<"$skill")
: "${skill_id:?skill create returned no id: $skill}"
echo "$skill_id" > "$here/.skill_id"
echo "    skill id: $skill_id (saved to scripts/.skill_id)"
