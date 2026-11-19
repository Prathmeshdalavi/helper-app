# Database (PostgreSQL 16)

**Single source of truth for schema: Flyway migrations in
`backend/src/main/resources/db/migration/`.** This folder deliberately holds no
second copy of the schema; it holds everything *around* it.

| Path | Purpose |
|---|---|
| `init/` | Runs once on first local container start (extensions only). |
| `seeds/` | Dev-only sample data. |
| `docs/data-model.md` | Conventions and the module-to-table map. |

## Rules

- Migrations are `V<n>__<module>_<what>.sql`, never edited after merge; fix forward.
- Entities (JPA models) live in each backend module's `domain/` package.
- `spring.jpa.hibernate.ddl-auto=validate`: Hibernate never changes the schema.
- Tables: plural snake_case; PK `id uuid`; `created_at`/`updated_at timestamptz`.
- Store money as integer minor units (paise) plus a currency code, never floats.

## Local

```bash
cp .env.example .env
docker compose up -d
```
