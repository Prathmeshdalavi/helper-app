# API conventions

- Base path `/api/v1`. Breaking changes ship as `/api/v2`.
- JSON, `camelCase` fields, ISO-8601 UTC timestamps, UUID ids, money as integer paise + currency.
- Plural nouns: `GET /bookings`, `POST /bookings`, `GET /bookings/{id}`.
- Lists are paginated: `?page=0&size=20`.

## Envelope

```json
{ "success": true,  "data": { }, "timestamp": "2026-11-19T10:00:00Z" }
{ "success": false, "error": { "code": "VALIDATION_FAILED", "message": "…", "details": { "phone": "invalid" } }, "timestamp": "…" }
```

Error codes and HTTP statuses: `shared/contracts/error-codes.json`.
Public routes: `/api/v1/auth/**`, `/api/v1/system/ping`, `/actuator/health`.
Admin routes: `/api/v1/admin/**` (role `ADMIN`).
