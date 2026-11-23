# HerCare API contract, milestone 1 (auth + users)

Base URL: `/api/v1`. JSON. Every response uses the envelope:

```json
{ "success": true,  "data": { }, "timestamp": "2026-11-23T10:00:00Z" }
{ "success": false, "error": { "code": "OTP_INVALID", "message": "…", "details": { } }, "timestamp": "…" }
```

Phone numbers are the 10-digit Indian mobile number the customer app already uses
(`^[6-9][0-9]{9}$`, no `+91`). Authenticated calls send `Authorization: Bearer <accessToken>`.

## Sign-in / sign-up flow (what the customer app screens map to)

1. Login screen "Proceed" → `check-phone` → `registered` true = go to OTP, false = go to Sign-up form.
2. Sign-up form "Continue" → (no server call; keeps name/email for step 4).
3. OTP screen opens (and "Resend OTP") → `send-otp`.
4. OTP entered (4 digits) → `verify-otp` (send `name`/`email` for a new user) → tokens + user.
5. Store tokens in secure storage; on app start call `users/me`, on 401 call `refresh`.
6. Account tab "Log out" → `logout`, then clear tokens.

## Endpoints

| Method + path | Auth | Request | Success data |
|---|---|---|---|
| `POST /auth/check-phone` | none | `{ "phone": "9876543210" }` | `{ "registered": true }` |
| `POST /auth/send-otp` | none | `{ "phone": "9876543210" }` | `{ "resendAfterSeconds": 15, "expiresInSeconds": 300 }` |
| `POST /auth/verify-otp` | none | `{ "phone", "otp": "4821", "name"?, "email"? }` | `{ accessToken, refreshToken, tokenType: "Bearer", expiresIn: 900, isNewUser, user }` |
| `POST /auth/refresh` | none | `{ "refreshToken": "…" }` | same as verify-otp, `user` omitted |
| `POST /auth/logout` | access token | `{ "refreshToken": "…" }` | none (idempotent) |
| `GET /users/me` | access token | none | `{ id, name, phone, email, createdAt }` |

`name` and `email` are only used when the phone has no account yet. Name: 2-60 chars, no
digits. Email: optional, `x@y.z` shape. For an existing account they are ignored.

## Errors

| HTTP | `error.code` | When |
|---|---|---|
| 400 | `VALIDATION_FAILED` | Bad field (see `details`), malformed JSON |
| 400 | `OTP_INVALID` | Wrong OTP. `details.remainingAttempts` |
| 400 | `OTP_EXPIRED` | OTP expired, already used, or never requested |
| 401 | `UNAUTHORIZED` | Missing/invalid access token; invalid, expired or reused refresh token |
| 403 | `FORBIDDEN` | Wrong role, or the account is blocked |
| 429 | `OTP_LOCKED` | 5 wrong attempts; request a new OTP |
| 429 | `RATE_LIMITED` | Too many requests. `details.retryAfterSeconds` |
| 503 | `SMS_UNAVAILABLE` | No SMS provider configured (always the case in prod today) |

## Security rules

- OTP: 4 digits, `SecureRandom`, valid 5 min, single use, 5 attempts, 15 s resend cooldown. Stored only as an HMAC-SHA256 hash keyed with `OTP_PEPPER`.
- `check-phone` returns no account data, but it still reveals whether a number is registered (the app UI branches on it). It is rate limited (30/10 min per IP, 10/10 min per phone).
- Limits: send-otp 20/h per IP and 5/h per phone; verify-otp 60/h per IP and 15/h per phone; refresh 120/h per IP.
- Access token: HS256 JWT, 15 min, claims `sub` (user id), `roles`, `iss`, `jti`. Refresh token: random, 30 days, stored hashed, replaced on every use; reusing an old one revokes that whole login.
- Rate limiting uses the TCP remote address. Behind a proxy/load balancer, configure `server.forward-headers-strategy` and trust only your proxy, otherwise all users share one IP.

## Required configuration

| Variable | Purpose |
|---|---|
| `DB_USER` / `DB_PASSWORD` (dev), `DB_URL` / `DB_USERNAME` / `DB_PASSWORD` (prod) | PostgreSQL |
| `JWT_SECRET` | 32+ bytes, no default in prod |
| `OTP_PEPPER` | 32+ bytes, no default in prod |
| `SMS_PROVIDER` | `none` until a provider is integrated; dev profile uses `log` (prints the OTP to the log) |

## Running the DB-backed integration tests

Create a dedicated empty database (its URL must contain `test`), then:

```bash
export TEST_DB_URL=jdbc:postgresql://localhost:5432/helper_app_test
export TEST_DB_USER=...   TEST_DB_PASSWORD=...
./mvnw test -Dtest=AuthFlowIntegrationTest
```

Without these variables the integration tests are skipped.
