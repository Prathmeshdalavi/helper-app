# Architecture

```
Flutter app ─┐
             ├─ HTTPS /api/v1 (JSON, JWT) ─► Spring Boot ─► PostgreSQL
Admin web ───┘                                   │
                                                 ├─► Redis (cache, OTP, rate limits)
                                                 └─► FCM / SMS / payment gateway (adapters)
```

## Backend: modular monolith

One deployable, split into feature modules under `com.helper_backend.modules.*`
(`auth user helper address catalog booking payment offer notification support admin`).
Each module has `controller → service → repository → domain (+ dto)`.

Rules:
1. A module calls another module only through its **service** classes, never its repositories or entities.
2. DTOs cross the API boundary; entities never do.
3. Cross-cutting code lives in `config/` and `common/` and contains no business logic.
4. External providers (payments, SMS, push) sit behind an interface in the owning module so they can be swapped and mocked.
5. If a module later needs its own service, its boundary is already clean.

## Mobile: feature-first

`lib/app` (bootstrapping, router, theme), `lib/core` (config, network, storage, errors),
`lib/features/<feature>/{data,domain,presentation}`, `lib/shared` (reusable widgets).
Riverpod for state and DI; go_router for navigation; Dio for HTTP.

## Admin web: feature folders

`src/app` (providers, router), `src/api` (HTTP client), `src/features/*`,
`src/components`, `src/pages`. React Query for server state.

## Data

PostgreSQL via Flyway migrations (see `database/README.md`). Redis for ephemeral state only.
