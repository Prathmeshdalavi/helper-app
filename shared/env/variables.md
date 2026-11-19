# Environment variables

| Variable | Used by | Notes |
|---|---|---|
| `DB_URL` | backend | JDBC URL. Dev default `jdbc:postgresql://localhost:5432/hercare`. Required in prod. |
| `DB_USERNAME` / `DB_PASSWORD` | backend | Required in prod, from a secret manager. |
| `DB_NAME` / `DB_PORT` | docker-compose | Local Postgres container. |
| `REDIS_HOST` / `REDIS_PORT` / `REDIS_PASSWORD` | backend | Cache, OTP and rate-limit state. |
| `JWT_SECRET` | backend | 32+ bytes. No default in prod; the app refuses to start without it. |
| `CORS_ALLOWED_ORIGINS` | backend | Comma-separated admin web origins. |
| `SPRING_PROFILES_ACTIVE` | backend | `dev` (default) or `prod`. |
| `VITE_API_BASE_URL` | admin-web | Public value only. |
| `API_BASE_URL`, `APP_ENV` | mobile | Via `--dart-define-from-file=env/<env>.json`. Public values only. |

Rules: real values never enter git; only `.env.example` files do. Anything shipped
to a browser or app binary is public, so it can never be a secret.
