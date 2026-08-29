# GitHub setup — estado aplicado

Repo: https://github.com/colome/CICDgithubActions (público)

## Hecho automáticamente

### Environments
| Environment | Reglas | Variables |
|-------------|--------|-----------|
| `staging` | solo branch `main` | `API_URL`, `NODE_ENV=staging` |
| `production` | required reviewers (`@colome`) + wait 5 min + solo `main` | `API_URL`, `NODE_ENV=production` |
| `preview` | sin approval | `API_URL`, `NODE_ENV=preview` |

### Branch protection (`main`)
- Require 1 approving review
- Status checks: `Lint`, `Test`, `Build`
- Dismiss stale reviews

### Código
- Push inicial a `main` (sin secretos; `.env` ignorado)

## Pendiente (necesita tus tokens)

Crea estos **Repository secrets** en  
https://github.com/colome/CICDgithubActions/settings/secrets/actions

| Secret | Dónde obtenerlo |
|--------|-----------------|
| `RENDER_API_KEY` | https://dashboard.render.com/u/settings#api-keys |
| `RENDER_STAGING_SERVICE_ID` | Dashboard del servicio staging |
| `RENDER_PRODUCTION_SERVICE_ID` | Dashboard del servicio production |
| `RENDER_PREVIEW_SERVICE_ID` | Dashboard del servicio preview |
| `SLACK_WEBHOOK_URL` | Slack App → Incoming Webhooks |

Cuando los tengas, puedes pegármelos (o decirme que los configures tú) y los cargo con `gh secret set`.

### Crear servicios en Render (web)
1. New → Web Service → conectar repo `colome/CICDgithubActions`
2. Build: `npm install` · Start: `npm start` · Health: `/health`
3. Tres servicios (staging / production / preview) o uno y clonar
4. Copiar cada Service ID a los secrets de arriba

### Actualizar `API_URL` reales
Cuando Render dé las URLs `*.onrender.com`, actualiza las variables de cada Environment (ahora hay placeholders `mi-cd-pipeline-*.onrender.com`).
