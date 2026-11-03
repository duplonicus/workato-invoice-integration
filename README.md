# workato-invoice-integration

A small, fully tested Workato integration built in Workato's free Developer Sandbox: an `invoice.paid` webhook is filtered, transformed and posted to a REST API with retries and failure alerts, then exposed as an MCP tool that Claude Code can call. The recipes are kept here as code (pulled with Workato's `wk` CLI), and every step has a script equivalent.

It's a practice project: the "finance API" is [httpbin.org](https://httpbin.org) (an echo service), and the payloads are made up.

## What it does

```
POST invoice.paid JSON ──> Webhook trigger ──> IF event_type == invoice.paid (others: no job)
                                │
                                ├─ Log "Paid INV-…: 1,299.00 CAD"   (cents -> currency formula)
                                ├─ TRY   HTTP POST /post  {invoice_id, customer_email, amount, currency, paid_at, source}
                                │  CATCH retry 3x, 5 s apart -> log error -> Stop job (Failed) -> email alert
                                └─ Log "Posted INV-… : HTTP 200, echoed amount 1299.0"

Claude Code ──MCP (Streamable HTTP)──> Workato MCP server "finance-practice" ──> skill post_invoice
                                                                               (HTTP POST -> {status_code, echoed_amount})
```

## Tested

| Case | Input | Result |
|---|---|---|
| Happy path | `samples/invoice_paid.json` | job Successful; API echoed `amount: 1299.0`; success log `HTTP 200, echoed amount 1299.0` |
| Filtered event | `samples/invoice_failed.json` (`invoice.payment_failed`) | 200 from the webhook, no job created |
| API down | HTTP URL set to `/status/503` | 3 retries 5 s apart, then job **Failed**: "503 Service Unavailable", email alert |
| Agent call | Claude Code: "post invoice INV-2026-0042 for 129900 cents CAD" | MCP `tools/call` -> `{"status_code":200,"echoed_amount":1299.0}` |

## Layout

| Path | What it is |
|---|---|
| `recipes/invoice_paid.recipe.json` | The webhook recipe as Workato JSON (`wk pull`): trigger + filter, logger, `try`/`catch` around `rest/make_request_v2`, stop-with-error |
| `recipes/post_invoice.recipe.json` | The MCP skill (Start workflow -> HTTP -> Return response) |
| `connections/httpbin_no_auth.connection.json` | HTTP connection (no auth, no secrets) |
| `samples/` | Test payloads |
| `scripts/send_test_event.sh` | Fire a test webhook (`curl`) |
| `scripts/post_invoice.sh` | The recipe's transform + POST in `jq` + `curl` |
| `scripts/post_with_retry.sh` | The recipe's error handling in bash: 3 retries, 5 s, non-zero exit on failure |
| `scripts/setup_cli.sh`, `wk.sh`, `sync.sh` | `wk` CLI login, project init, pull/push |
| `scripts/create_skill.sh` | Import the skill recipe, start it, register it as a skill (`wk`) |
| `scripts/create_mcp_server.sh` | Create the MCP server with the skill as its tool (Developer API `POST /api/mcp/mcp_servers`) |
| `scripts/mcp_connect.sh` | Register the Workato MCP server in Claude Code (token read hidden) |
| `CHEATSHEET.md` | Workato concepts, formulas, CLI and MCP notes from building this |

## Reproduce

Needs `curl`, `jq` and Workato's [`wk` CLI](https://github.com/workato-devs/wk).

1. Free Developer Sandbox at workato.com, then an API client (see the top of `scripts/setup_cli.sh` for the role).
2. `scripts/setup_cli.sh <project>` to log in and pull. Import or push the recipe JSON, start the recipe in the web app.
3. Copy the webhook URL from the trigger, then `scripts/send_test_event.sh <url>` and `scripts/send_test_event.sh <url> samples/invoice_failed.json`.
4. For the agent part: `scripts/create_skill.sh <folder-id>`, `scripts/create_mcp_server.sh <folder-id>`, then `scripts/mcp_connect.sh`. The skill and server were built in the web app; these two scripts are the code version of those steps and haven't been run end to end (a skill can't be deleted through the API). See the comment at the top of `create_mcp_server.sh` for the one open question about the tool id.

Secrets never live in this repo: the wk token is in a gitignored `profiles.env`, and the MCP token only in Claude Code's own config.
