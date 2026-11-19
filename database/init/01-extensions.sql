-- Runs once when the local Postgres container is first created.
-- Schema itself is owned by Flyway (backend/src/main/resources/db/migration).
CREATE EXTENSION IF NOT EXISTS pg_trgm;
