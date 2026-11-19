# ADR 0001: Keep the existing Spring Boot backend

**Status:** accepted

**Context:** `backend/` already exists as Spring Boot 4.1.2 / Java 21 / Maven with JPA, Flyway, Redis, Security (OAuth2 resource server), Validation and PostgreSQL.

**Decision:** Keep it unchanged as the platform API; do not introduce a second backend stack. Existing package `com.helper_backend` and `pom.xml` are preserved. Build as a modular monolith (see `docs/architecture.md`).

**Consequences:** Flyway in `backend/` is the single schema source. New tooling (Flutter, React admin) was added around it. Payments/notifications are added as adapters later, with no new dependency chosen yet.
