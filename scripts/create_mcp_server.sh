#!/usr/bin/env bash
# Create the finance-practice MCP server with the post_invoice skill as its tool
# (what was done in the web app with Create > MCP server > Project assets).
# Calls Workato's Developer API directly (docs: docs.workato.com/en/workato-api/mcp-servers.html):
#   POST /api/mcp/mcp_servers   {name, description, folder_id, tools:[{trigger_application, id}]}
#   The response is wrapped in .data; the server handle is .data.id (mcps-..., checked on a live
#   server with GET; the docs' example shows a number), and .data.mcp_url carries the token: it is
#   deleted before printing, never print or commit it.
# The API token comes from the wk profile (wk auth token), so nothing is typed or stored here.
#
# trigger_application: a skill tool on a live server reads back as "workato_skill" (with flow_id =
# the skill's recipe id), although the API docs list only workato_genie, workato_recipe_function and
# workato_api_platform. NOT verified: whether a workato_skill tool's "id" is the skill id (skl-...)
# or the recipe id. The default below is the skill id; if the API rejects it, pass the recipe id:
#   ../scripts/create_mcp_server.sh <folder-id> "$(cat ../scripts/.recipe_id)"
# CLI alternative (recipe-backed tools): ../scripts/wk.sh mcp servers create --name ... --folder-id ... --recipe <id>
#
# Usage: ./create_mcp_server.sh <folder-id> [tool-id] [trigger_application]
#   tool-id defaults to scripts/.skill_id (written by create_skill.sh)
#   trigger_application defaults to workato_skill; recipe functions use workato_recipe_function
# Needs: wk, jq, curl.
# Run it from the wk project dir (workspace/): wk finds a file-store profile only in the current folder.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
base="${WORKATO_BASE:-https://app.trial.workato.com}"
folder="${1:?usage: create_mcp_server.sh <folder-id> [tool-id] [trigger_application]}"
tool_id="${2:-$(cat "$here/.skill_id" 2>/dev/null || true)}"
: "${tool_id:?no tool id: run create_skill.sh first or pass it}"
app="${3:-workato_skill}"

body=$(jq -n --arg n "finance-practice" --argjson f "$folder" --arg app "$app" --arg id "$tool_id" \
  --arg d "Practice finance tools. post_invoice sends a paid invoice to a test finance API (httpbin echo). Always confirm with the user before calling it." \
  '{name:$n, description:$d, folder_id:$f, tools:[{trigger_application:$app, id:$id}]}')

token=$("$here/wk.sh" auth token)
resp=$(curl -sS --fail-with-body -X POST "$base/api/mcp/mcp_servers" \
  -H "Authorization: Bearer $token" -H 'Content-Type: application/json' -d "$body") || {
  unset token
  echo "create failed:" >&2
  jq 'del(.data.mcp_url)' <<<"$resp" >&2 2>/dev/null || grep -v wkt_token <<<"$resp" >&2
  exit 1
}
unset token
# Show the server without its URL/token.
jq '.data | del(.mcp_url) | {handle: .id, name, tools_count}' <<<"$resp"
echo "Get the connect URL from the server's Details page, then: ../scripts/mcp_connect.sh <remote-mcp-base-url>"
