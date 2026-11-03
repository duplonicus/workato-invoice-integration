# Workato cheat sheet

Notes from building this repo in a Developer Sandbox (Nov 2026). UI labels are as they appeared then.

## Where things live

| Thing | Where |
|---|---|
| Projects, recipes, connections | **Projects** > project > **Create** (Recipe, Connection, Skill, MCP server, Data table, …) |
| API tokens for the CLI | **Workspace admin > API clients** (first **Client roles**, then **API client**; token shown once) |
| Recipe sharing | recipe > **Settings > Sharing** (collapsed section). Private links require a Workato login |
| Jobs / history | recipe > **Jobs**, or **TEST** view in the editor (**Repeat job** replays the last event) |
| Step menu (copy, paste, delete) | the **⋯** to the right of a step card |
| MCP servers | **Enterprise MCP**, or **Create > MCP server** |

## Core ideas

- **Recipe** = one **trigger** + **actions**. A recipe only processes events while **started** (Test mode is separate).
- **Trigger condition** filters events before a job exists (no job, no task cost). Clean form: pill / *equals* / value.
- **Data pills** are references to a step's output, stored as `_dp('{"provider":…,"line":"<step id>","path":[…]}')`. You drag them because there are no typeable variable names; renaming steps doesn't break them.
- **Text vs formula mode** (the `fx` toggle): text mode concatenates literally; formula mode runs Ruby-like code on the pills.
- **Job viewer:** `{}` means *collapsed*, not empty. Check the line numbers (14 → 39 = 24 hidden lines) or **Expand data**.
- **concurrency: 1** (recipe setting) = jobs run one at a time, in order.

## Formulas used

```ruby
(amount_cents / 100.0).to_currency(unit: currency, format: "%n %u")   # 129900 -> "1,299.00 CAD"
amount_cents / 100.0                                                  # 1299.0 (number for APIs)
status_code.to_s                                                      # numbers must be .to_s before + "text"
```

- `/ 100` with two integers is **integer division** (drops cents). Use `/ 100.0`.
- `to_currency` options: `unit`, `format` (`%n` number, `%u` unit), `precision`, `delimiter`, `separator`, `negative_format`.

## HTTP connector

- Connection: auth **None**, **Base URL** `https://httpbin.org`, then relative Request URL `/post`.
- **JSON request body** = one field per key (Workato handles quoting); **Raw JSON** = type the JSON yourself (easy to break).
- **Response content type JSON** + response schema (Use JSON from a sample) -> pills like `Response > json > amount`.
- Non-2xx = error by default (**Mark non-2xx response codes as success?** = No).

## Error handling

- **Handle errors** = `try` / `catch` in the recipe JSON. Put the risky step *inside* the Monitor block (drag = cut + paste).
- **On error:** retry up to 3 times, 1–10 s apart; optional **Retry IF** condition. Pills: Error type, Error message, Retry count.
- After retries: log, then **Stop job** "with error" (marked **Failed**) so failures are visible; Workato emails failed-job alerts.
- **No error** path continues after the whole block: a good place for a success log.

## wk CLI (Workato Labs, experimental)

```bash
wk auth login --store-type file          # interactive: paste token, region trial; writes profiles.env (gitignore it)
wk init --project "test"                  # links the local folder to a Workato project
wk pull | wk status | wk diff | wk push   # file-store profiles need: --profile <name> --store-type file
wk recipes --help                         # list/get/start/stop/import/update/jobs (check flags with --help)
wk mcp servers --help                     # create, tools add/remove, token-renew
```

- 401 `missing_privilege` on login = the client role lacks `GET /api/users/me` (Admin tab).
- `Package archive is not ready` = project is empty (nothing to export yet).

## Skills and MCP

- A **skill** = recipe with **Start workflow** trigger (inputs schema + description) and **Return response** (result schema). That's what becomes an MCP tool.
- An **MCP server** groups skills behind one remote URL (`https://<id>.apim.mcp.trial.workato.com/?wkt_token=…`). Tools show **Inactive** until the skill recipe is started.
- Local MCP servers run as processes over **stdio**; Workato's is **remote**, over **Streamable HTTP**: each `tools/call` becomes a Workato job.
- "Require user confirmation" on a skill depends on the MCP client honouring it; Claude Code called the tool without prompting. Enforce real approvals with permissions/policies.
- Use agents for judgment-heavy, ad hoc work (exceptions, cross-system questions) through narrow skills; keep deterministic flows as plain recipes.
