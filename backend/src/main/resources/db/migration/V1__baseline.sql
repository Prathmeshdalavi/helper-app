-- V1 baseline. Each module's schema arrives in its own versioned migration:
--   V2__auth_users.sql, V3__catalog.sql, ...   (never edit an applied migration)
-- Conventions: snake_case plural tables, UUID primary keys, created_at/updated_at timestamptz.
CREATE EXTENSION IF NOT EXISTS pg_trgm;
