#!/usr/bin/env bash
# Dispara un deploy en Render y espera a que esté live.
# Requiere: RENDER_API_KEY, RENDER_SERVICE_ID
set -euo pipefail

API="https://api.render.com/v1"
AUTH="Authorization: Bearer ${RENDER_API_KEY:?RENDER_API_KEY required}"
SERVICE_ID="${RENDER_SERVICE_ID:?RENDER_SERVICE_ID required}"

echo "Triggering deploy for service $SERVICE_ID"
DEPLOY_JSON=$(curl -sS -X POST \
  -H "$AUTH" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"clearCache":"do_not_clear"}' \
  "$API/services/$SERVICE_ID/deploys")

DEPLOY_ID=$(echo "$DEPLOY_JSON" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('id') or d.get('deploy',{}).get('id') or '')")
if [[ -z "$DEPLOY_ID" ]]; then
  echo "Unexpected deploy response: $DEPLOY_JSON"
  exit 1
fi
echo "Deploy id: $DEPLOY_ID"

for i in $(seq 1 60); do
  STATUS_JSON=$(curl -sS -H "$AUTH" -H "Accept: application/json" \
    "$API/services/$SERVICE_ID/deploys/$DEPLOY_ID")
  STATUS=$(echo "$STATUS_JSON" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('status') or d.get('deploy',{}).get('status') or '')")
  echo "Attempt $i: status=$STATUS"
  case "$STATUS" in
    live) echo "Deploy live"; exit 0 ;;
    update_failed|build_failed|canceled|deactivated)
      echo "Deploy failed: $STATUS"
      echo "$STATUS_JSON"
      exit 1
      ;;
  esac
  sleep 10
done

echo "Timeout waiting for deploy"
exit 1
