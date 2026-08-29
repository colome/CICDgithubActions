#!/usr/bin/env bash
# Notifica a Slack (Incoming Webhook). Si SLACK_WEBHOOK_URL no está, solo imprime.
set -euo pipefail

STATUS="${1:?status required (success|failure|rollback)}"
TITLE="${2:?title required}"
DETAILS="${3:-}"

echo "Notify [$STATUS]: $TITLE"
echo "$DETAILS"

if [[ -z "${SLACK_WEBHOOK_URL:-}" ]]; then
  echo "SLACK_WEBHOOK_URL not set — skip Slack"
  exit 0
fi

COLOR="good"
[[ "$STATUS" == "failure" ]] && COLOR="danger"
[[ "$STATUS" == "rollback" ]] && COLOR="warning"

payload=$(STATUS="$STATUS" TITLE="$TITLE" DETAILS="$DETAILS" COLOR="$COLOR" \
  GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-local}" \
  GITHUB_ACTOR="${GITHUB_ACTOR:-local}" \
  GITHUB_SHA="${GITHUB_SHA:-n/a}" \
  python3 - <<'PY'
import json, os
text = (
  f"*{os.environ['TITLE']}*\n"
  f"{os.environ.get('DETAILS','')}\n"
  f"Repo: {os.environ.get('GITHUB_REPOSITORY')}\n"
  f"Actor: {os.environ.get('GITHUB_ACTOR')}\n"
  f"SHA: {os.environ.get('GITHUB_SHA')}"
)
print(json.dumps({
  "attachments": [{
    "color": os.environ["COLOR"],
    "text": text,
    "mrkdwn_in": ["text"],
  }]
}))
PY
)

curl -sS -X POST -H "Content-Type: application/json" -d "$payload" "$SLACK_WEBHOOK_URL" >/dev/null
echo "Slack notified"
