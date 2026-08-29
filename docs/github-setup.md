# Docs de configuración (no contiene secretos)
# Copia estos valores en GitHub → Settings → Environments / Secrets

## Repository secrets
# RENDER_API_KEY
# RENDER_STAGING_SERVICE_ID
# RENDER_PRODUCTION_SERVICE_ID
# RENDER_PREVIEW_SERVICE_ID
# SLACK_WEBHOOK_URL
# PREVIEW_BASE_URL (opcional si no usas vars del env preview)

## Environment: staging
# Protection: Deployment branches = main (sin required reviewers)
# Variables:
#   API_URL=https://mi-cd-pipeline-staging.onrender.com
#   NODE_ENV=staging
# Secrets (opcionales):
#   DATABASE_URL=...

## Environment: production
# Protection: Required reviewers + Wait timer 5 min + Deployment branches = main
# Variables:
#   API_URL=https://mi-cd-pipeline.onrender.com
#   NODE_ENV=production
# Secrets (opcionales):
#   DATABASE_URL=...

## Environment: preview
# Variables:
#   API_URL=https://mi-cd-pipeline-preview.onrender.com

## Branch protection (main)
# Require PR reviews (1)
# Require status checks: Lint, Test, Build (ci.yml)
