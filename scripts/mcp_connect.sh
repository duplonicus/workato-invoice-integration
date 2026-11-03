#!/usr/bin/env bash
# Connect Claude Code to the Workato MCP server that exposes the post_invoice skill.
# Get the Remote MCP URL from the server's Details page (Access method: Token-based access;
# the token comes from Edit). The URL looks like https://<id>.apim.mcp.trial.workato.com/?wkt_token=<token>
# The token is read hidden and never echoed. Note: Claude Code stores the full URL (with token)
# in ~/.claude.json, so never commit that file.
set -euo pipefail
name="${1:-finance-practice}"
base="${2:?usage: mcp_connect.sh [name] <remote-mcp-base-url, e.g. https://1234.apim.mcp.trial.workato.com/>}"
read -rsp "Paste MCP token (hidden): " token; echo
claude mcp add --transport http "$name" "${base%/}/?wkt_token=${token}"
unset token
claude mcp list
echo 'Try in claude: "Use finance-practice to post invoice INV-2026-0042 for 129900 cents CAD, customer ap@example.com."'
echo 'Expected result: {"status_code":200,"echoed_amount":1299.0}'
