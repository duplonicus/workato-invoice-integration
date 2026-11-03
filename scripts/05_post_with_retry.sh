#!/usr/bin/env bash
# Code twin of Stop 8 (Handle errors: Monitor block + On error, 3 retries, 5 s apart).
# POSTs the invoice body; on a non-2xx it retries up to 3 times, then logs the failure
# and exits non-zero (like the recipe's On error block + Stop job).
# Usage: ./05_post_with_retry.sh [url] [payload.json]
#   url default https://httpbin.org/post ; use https://httpbin.org/status/503 to force failures.
set -uo pipefail
url="${1:-https://httpbin.org/post}"
payload="${2:-$(dirname "$0")/../samples/invoice_paid.json}"
out=$(mktemp); trap 'rm -f "$out"' EXIT
body=$(jq -c '{invoice_id, customer_email, amount: (.amount_cents / 100), currency, paid_at, source: "workato-practice"}' "$payload") \
  || { echo "bad payload: $payload" >&2; exit 2; }
max_retries=3; interval=5
for attempt in $(seq 0 "$max_retries"); do
  code=$(curl -sS -o "$out" -w '%{http_code}' -X POST "$url" -H 'Content-Type: application/json' --data-binary "$body")
  if [[ "$code" =~ ^2 ]]; then echo "OK $code on attempt $((attempt+1))"; exit 0; fi
  echo "attempt $((attempt+1)) failed: HTTP $code"
  (( attempt < max_retries )) && sleep "$interval"
done
echo "ERROR: gave up after $max_retries retries (invoice $(jq -r .invoice_id "$payload"), last HTTP $code)" >&2
exit 1
