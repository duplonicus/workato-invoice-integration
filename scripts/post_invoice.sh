#!/usr/bin/env bash
# Code twin of the recipe's HTTP action (Stop 7): turn the webhook payload into the
# finance-shaped body and POST it as JSON to https://httpbin.org/post (an echo API).
# Usage: ./post_invoice.sh [payload.json]   (default: ../samples/invoice_paid.json)
# Needs: jq, curl.
set -euo pipefail
payload="${1:-$(dirname "$0")/../samples/invoice_paid.json}"
body=$(jq '{invoice_id, customer_email, amount: (.amount_cents / 100), currency, paid_at, source: "workato-practice"}' "$payload")
echo "Request body:"; echo "$body"
echo "Response (httpbin echoes what it received under .json):"
curl -sS -X POST https://httpbin.org/post -H 'Content-Type: application/json' --data-binary "$body" | jq '{status: "echo", json}'
