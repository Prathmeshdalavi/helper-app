# Security baseline

- **Auth:** short-lived access JWT (15 min, HS256 today) + refresh token (30 d, stored hashed, rotated on use). Roles in the `roles` claim.
- **Secrets:** environment variables only; prod config has no defaults. `.env` files are git-ignored.
- **Passwords/PINs:** BCrypt (cost 12). OTPs expire, are single-use and rate-limited (Redis).
- **Input:** validate every DTO with Bean Validation; never build SQL by string concatenation (use JPA/parameters).
- **Transport:** HTTPS only in staging/prod; CORS limited to `CORS_ALLOWED_ORIGINS`.
- **Errors:** no stack traces or internals in responses (`GlobalExceptionHandler`).
- **Mobile:** tokens in the platform keystore (`flutter_secure_storage`); no secrets in the app binary.
- **Admin web:** keep the access token in memory, not `localStorage`.
- **Payments:** never store card data; use the gateway's hosted flow and verify webhooks by signature.
- **Dependencies:** review Dependabot/CI audit results weekly.

Before go-live consider moving JWT signing to asymmetric keys (RS256) so other services can verify without holding the secret.
