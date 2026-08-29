#!/usr/bin/env bash
# Health check con reintentos.
# Uso: BASE_URL=https://x.com ./scripts/healthcheck.sh
set -euo pipefail

BASE_URL="${BASE_URL:?BASE_URL required}"
BASE_URL="${BASE_URL%/}"
RETRIES="${RETRIES:-12}"
SLEEP_SECS="${SLEEP_SECS:-10}"

for i in $(seq 1 "$RETRIES"); do
  code=$(curl -sS -o /tmp/health-body.txt -w "%{http_code}" "$BASE_URL/health" || true)
  if [[ "$code" == "200" ]]; then
    echo "Health OK (attempt $i): $(cat /tmp/health-body.txt)"
    exit 0
  fi
  echo "Attempt $i/$RETRIES -> HTTP $code"
  sleep "$SLEEP_SECS"
done

echo "Health check failed after $RETRIES attempts"
exit 1
