# Onboarding

1. Install JDK 21, Flutter 3.x, Node 22, Docker.
2. `cp .env.example .env`, then `docker compose up -d`.
3. Backend: `cd backend && ./mvnw spring-boot:run`. Check `GET http://localhost:8080/api/v1/system/ping`.
   The `dev` profile is the default; override secrets with env vars.
4. Mobile: `cd mobile && flutter pub get && flutter run --dart-define-from-file=env/dev.json`.
   Android emulator reaches the host at `10.0.2.2`; a real phone needs your LAN IP in `env/dev.json`.
5. Admin: `cd admin-web && cp .env.example .env.local && npm install && npm run dev`.

## Adding a feature (example: booking)

- Backend: code in `modules/booking/*`, schema in a new `V<n>__booking_*.sql`.
- Mobile: `lib/features/booking/{data,domain,presentation}`; register routes in `app/router/app_router.dart`.
- Admin: `src/features/bookings`; register routes in `src/app/router.tsx`.
- Shared enums/codes: update `shared/contracts/` and all three apps together.
