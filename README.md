# HerCare: home helper services platform

Monorepo: one repository, four deployable parts.

| Folder | What | Stack |
|---|---|---|
| `backend/` | REST API, auth, bookings, payments, notifications | Spring Boot 4.1, Java 21, Maven |
| `mobile/` | Customer app, Android and iOS | Flutter, Riverpod, go_router, Dio |
| `admin-web/` | Admin dashboard | React, TypeScript, Vite |
| `database/` | Local DB init, seeds, data-model docs (schema = Flyway in `backend/`) | PostgreSQL 16 |
| `shared/` | Cross-app contracts and env documentation | JSON, Markdown |
| `docs/` | Architecture, API conventions, security, workflow | Markdown |

## Quick start

```bash
cp .env.example .env
docker compose up -d                       # Postgres + Redis

cd backend && ./mvnw spring-boot:run       # http://localhost:8080/api/v1/system/ping
cd mobile && flutter run --dart-define-from-file=env/dev.json
cd admin-web && npm install && npm run dev # http://localhost:5173
```

Requires JDK 21, Flutter 3.x, Node 22, Docker. Read `docs/onboarding.md` next.
