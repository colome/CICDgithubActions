# Comparativa: `CICDgithubActions` vs `CICDgithubActionsPRO`

Documento de comparación entre la **propuesta propia** (`CICDgithubActions`) y la **solución oficial del PDF** (`CICDgithubActionsPRO`) del reto *GitHub Actions — CD Pipeline* (Sesión 18).

| | **CICDgithubActions** (propuesta) | **CICDgithubActionsPRO** (solución PDF) |
|--|--|--|
| Origen | Implementación propia del reto | Solución de referencia del PDF |
| Repo GitHub | [colome/CICDgithubActions](https://github.com/colome/CICDgithubActions) | [colome/CICDgithubActionsVercel](https://github.com/colome/CICDgithubActionsVercel) |
| Plataforma de deploy | **Render** (3 Web Services) | **Vercel** (1 proyecto) |
| Nombre npm | `mi-cd-pipeline` | `cd-pipeline-demo` |
| Tests | `node:test` + supertest | **Jest** + supertest |
| Contenerización | Sí (`Dockerfile` + `docker.yml` → GHCR) | No (solo Vercel) |
| Persistencia | Memoria (sin DB) | Memoria (sin DB) |

---

## 1. Similitudes

Ambas resoluciones cubren el mismo **esqueleto del reto**:

### Objetivo de CD
- Preview en PRs (URL comentada)
- Staging automático tras CI en `main`
- Production manual (`workflow_dispatch`) con Environment de GitHub
- Health checks post-deploy con reintentos
- Smoke tests / verificación de endpoints
- Rollback de emergencia
- Notificaciones Slack (opcionales vía secret)
- Secrets en GitHub (nunca hardcodeados)
- Concurrency por environment
- README con badges de CI/CD

### Stack de aplicación
- Node.js + **Express**
- Endpoints de salud e info (`/`, `/health`, …)
- ESLint + tests automatizados
- `.gitignore` que excluye `.env` y secretos locales

### GitHub Actions / Environments
- Workflows separados: CI, CD staging, CD production, rollback
- Environments: `preview` / `staging` / `production` (nombres equivalentes)
- Production pensado para approval / confirmación explícita
- Step summaries en varios jobs

---

## 2. Diferencias

### Plataforma y secrets

| Aspecto | Propuesta (Render) | Solución PDF (Vercel) |
|---------|--------------------|------------------------|
| Deploy CLI/API | `scripts/render-deploy.sh` + API Render | `vercel pull` / `vercel build` / `vercel deploy` |
| Secrets | `RENDER_API_KEY`, `RENDER_*_SERVICE_ID` | `VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID` |
| URLs estables | 3 servicios (`*-staging`, `*-prod`, `*-preview`) | 1 alias prod + previews temporales |
| Config extra | — | `vercel.json` |

### Estructura de workflows

| Aspecto | Propuesta | Solución PDF |
|---------|-----------|--------------|
| Preview | Workflow aparte `cd-preview.yml` | Job `deploy-preview` **dentro de** `ci.yml` |
| Staging trigger | `workflow_run` tras CI | `workflow_run` tras CI (igual idea) |
| Production confirm | `confirm=deploy-prod` | `confirm=deploy` |
| Docker / GHCR | `docker.yml` (bonus) | No |
| Soft-skip sin secrets | Sí (no falla si faltan tokens) | Parcial en preview; prod asume secrets |

### API de la aplicación

| | Propuesta | Solución PDF |
|--|-----------|--------------|
| Health | `status: "ok"` | `status: "healthy"` |
| Extra | `GET /api` | `GET /api/info`, `GET/POST /api/items` |
| Dominio demo | Solo health/info | CRUD mínimo de items (en memoria) |

### Testing y DX

| | Propuesta | Solución PDF |
|--|-----------|--------------|
| Runner de tests | Node built-in (`node --test`) | Jest |
| Smoke post-staging | `scripts/smoke.js` + health script | Jobs curl inline en el workflow |
| Scripts auxiliares | `render-deploy.sh`, `healthcheck.sh`, `notify-slack.sh` | Lógica mayormente en YAML |

---

## 3. Puntos fuertes

### `CICDgithubActions` (propuesta / Render)

- **Tres entornos reales** en Render (staging / prod / preview) con URLs fijas y Service IDs claros.
- **Docker + GHCR** como bonus de nivel avanzado.
- Scripts reutilizables (`smoke`, health, notify) más fáciles de probar fuera de Actions.
- Soft-skip cuando faltan secrets: CI/PR no se ponen rojos solo por falta de plataforma.
- Runtime “clásico” (Web Service siempre encendido en free/paid Render), más predecible para health checks.

### `CICDgithubActionsPRO` (solución PDF / Vercel)

- **Fidelidad al PDF**: Jest, Vercel CLI, preview embebido en CI, release en prod.
- DX de frontend/hosting moderno: deploys preview muy rápidos, integración nativa Vercel↔GitHub.
- API de demo más rica (`/api/items`) para smoke tests más realistas.
- Menos infra que mantener (un solo proyecto Vercel vs tres servicios Render).
- Documentación README muy completa (PowerShell, curls, links).

---

## 4. Puntos débiles

### `CICDgithubActions` (propuesta / Render)

- API más mínima (sin `/api/items`).
- Render free puede **dormir** instancias → health checks más lentos o flaky.
- Tres servicios = más IDs/secrets y más superficie de configuración.
- Menos “idéntica” a la solución oficial del curso (plataforma distinta).

### `CICDgithubActionsPRO` (solución PDF / Vercel)

- **Deployment Protection** en URLs temporales → health checks con **302** si no se usa el alias (`vars.API_URL`).
- Un solo proyecto: staging y preview se solapan conceptualmente (no hay “staging.app” separado por defecto).
- Serverless/cold starts: estado in-memory de items aún más frágil entre invocaciones.
- Sin Docker/GHCR (si el evaluador pide bonus de contenedores, no está).
- Warning de deprecación Node 20 en actions `checkout`/`setup-node` (cosmética).

### Comunes a ambas

- **Sin base de datos**: los datos viven en memoria RAM del proceso.
- Dependen de secrets externos (Render o Vercel) para que el CD real funcione.
- Plan free de GitHub limita algunas protection rules en repos privados (reviewers/wait timer).

---

## 5. ¿Cuál usar?

| Objetivo | Mejor opción |
|----------|--------------|
| Seguir el PDF al pie de la letra / entregar “solución del curso” | **CICDgithubActionsPRO** (Vercel) |
| Entornos staging/prod/preview claramente separados + Docker | **CICDgithubActions** (Render) |
| Portfolio / demostrar ambas plataformas | Mantener **ambas** y enlazar este documento |

Para un examen o rúbrica del PDF: prioriza **PRO**.  
Para un despliegue “tipo backend clásico” con tres URLs estables: prioriza la **propuesta Render**.

---

## 6. Resumen rápido

```
CICDgithubActions          CICDgithubActionsPRO
(propuesta)                (solución PDF)
     │                            │
     ├─ Render (3 services)       ├─ Vercel (1 project)
     ├─ node:test                 ├─ Jest
     ├─ Docker + GHCR             ├─ vercel.json
     ├─ cd-preview.yml aparte     ├─ preview dentro de ci.yml
     └─ /health status=ok         └─ /health healthy + /api/items
```

---

*Generado a partir del estado de ambos repos (Agosto 2026).*
