# mi-cd-pipeline

Pipeline de **Continuous Deployment** con GitHub Actions (reto Sesión 18).

[![CI](https://github.com/colome/CICDgithubActions/actions/workflows/ci.yml/badge.svg)](https://github.com/colome/CICDgithubActions/actions/workflows/ci.yml)
[![CD Staging](https://github.com/colome/CICDgithubActions/actions/workflows/cd-staging.yml/badge.svg)](https://github.com/colome/CICDgithubActions/actions/workflows/cd-staging.yml)
[![CD Production](https://github.com/colome/CICDgithubActions/actions/workflows/cd-production.yml/badge.svg)](https://github.com/colome/CICDgithubActions/actions/workflows/cd-production.yml)

> Sustituye `colome/CICDgithubActions` en los badges por tu usuario/organización y nombre del repo.

## Arquitectura

| Trigger | Workflow | Environment |
|---------|----------|-------------|
| `push` / `pull_request` → `main` | `ci.yml` | — |
| PR abierta/actualizada | `cd-preview.yml` | `preview` + comentario URL |
| CI OK en `main` (`workflow_run`) | `cd-staging.yml` | `staging` + smoke + Slack |
| Manual `workflow_dispatch` | `cd-production.yml` | `production` (approval) + Release |
| Manual emergencia | `rollback.yml` | `production` |
| Push `main` / tags | `docker.yml` | GHCR |

## App

Express mínimo:

- `GET /` — info
- `GET /health` — health check (200)
- `GET /api` — listado de endpoints

```bash
cp .env.example .env
npm install
npm run lint && npm test && npm start
# http://localhost:3000/health
```

## Secrets (GitHub → Settings → Secrets and variables)

| Secret | Uso |
|--------|-----|
| `RENDER_API_KEY` | Deploy Render |
| `RENDER_STAGING_SERVICE_ID` | Servicio staging |
| `RENDER_PRODUCTION_SERVICE_ID` | Servicio production |
| `RENDER_PREVIEW_SERVICE_ID` | Servicio preview (PRs) |
| `SLACK_WEBHOOK_URL` | Notificaciones |

**No hardcodees tokens** en workflows ni en el código. Usa Environments `staging` / `production` / `preview` con variables `API_URL`.

Guía detallada: [`docs/github-setup.md`](docs/github-setup.md)

## Deploy local (Docker)

```bash
docker build -t mi-cd-pipeline .
docker run --rm -p 3000:3000 mi-cd-pipeline
```

## Checklist del reto

- [x] CI: lint + test + build
- [x] CD staging automático tras CI en `main`
- [x] CD production manual + environment con approval
- [x] Health checks con reintentos
- [x] Secrets solo en GitHub Secrets (`.gitignore` estricto)
- [x] Preview deploys + comentario en PR
- [x] Smoke tests post-staging
- [x] Notificaciones Slack
- [x] GitHub Release en prod
- [x] Rollback workflow
- [x] Docker + GHCR + cache
- [x] Concurrency control por environment
- [ ] Configurar Environments + branch protection en GitHub (manual)
- [ ] Crear servicios en Render y pegar IDs/tokens como secrets

## Licencia

MIT
