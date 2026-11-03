#!/usr/bin/env bash
# Send a test event to the recipe's webhook URL (copy it from the trigger in the web app).
# Usage: ./03_send_test_event.sh <webhook-url> [payload.json]
# Default payload: ../samples/invoice_paid.json. Use ../samples/invoice_failed.json to check the
# trigger condition (event_type != invoice.paid): you still get 200, but no job is created.
# Expect: HTTP 200 and {"status":"ok"} (Workato's default webhook response).
set -euo pipefail
url="${1:?usage: 03_send_test_event.sh <webhook-url> [payload.json]}"
payload="${2:-$(dirname "$0")/../samples/invoice_paid.json}"
curl -sS -i -X POST "$url" -H 'Content-Type: application/json' --data-binary @"$payload"
echo
