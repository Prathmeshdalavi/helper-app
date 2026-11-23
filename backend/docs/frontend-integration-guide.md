# Customer app: connect sign-up / login to the backend

Audience: the Flutter developer. Scope: `mobile/customer_app` only. The backend (M1 auth +
M2 catalog) is finished, tested and live on `backend-dev`. **Do not change the backend or the
UI design.** Only the data layer, a few screen handlers and platform config change.

## 1. Why nothing is saved today

The auth screens use demo code and never call the server:

| File | Demo behaviour today |
|---|---|
| `lib/features/auth/data/auth_repository.dart` | `lookupName()` returns a name only for the fake number `9876543210` |
| `lib/features/auth/presentation/otp_screen.dart` | "verifies" locally: any 4 digits except `0000` pass; resend does nothing |
| `lib/features/auth/presentation/success_screen.dart` | signs in from local `AuthArgs` |
| `lib/features/auth/data/session.dart` | in-memory only, no tokens |
| `lib/core/network/api_client.dart` | Dio client exists, nothing uses it |

Result: the backend receives no request, so `users` in PostgreSQL stays empty.

## 2. Backend facts you can rely on

- Base URL: `http://10.0.2.2:8080/api/v1` (Android emulator, already in `env/dev.json`). Real phone: `http://<PC-LAN-IP>:8080/api/v1`. Production: HTTPS only.
- Every response uses one envelope:
  `{"success":true,"data":{...},"timestamp":"..."}` or
  `{"success":false,"error":{"code":"...","message":"...","details":{...}},"timestamp":"..."}`.
- Phone = the 10 digits the app already uses (no `+91`). Server rule: starts with 6-9, exactly 10 digits.
- Auth header for protected calls: `Authorization: Bearer <accessToken>`.
- **Dev OTP:** there is no SMS provider yet. The dev backend prints the OTP in its console, for example
  `DEV-ONLY sms provider: OTP for +91******3748 is 4821`. Read it from the backend log.

## 3. Endpoints

### 3.1 `POST /auth/check-phone` (public)
Request `{"phone":"9876543210"}` -> `{"data":{"registered":true}}`.
Returns **only** `registered` (no name). Use it exactly where `lookupName()` is used now:
`registered == true` -> go to OTP screen; `false` -> go to Sign-up screen.
The name for the OTP/success screens now comes from `verify-otp` (3.3).

### 3.2 `POST /auth/send-otp` (public)
Request `{"phone":"9876543210"}` -> `{"data":{"resendAfterSeconds":15,"expiresInSeconds":300}}`.
Call it **when the OTP screen opens** (today nothing sends the first OTP) and on "Resend OTP".
A second call within 15 s returns 429 `RATE_LIMITED` (`details.retryAfterSeconds`).
Use `resendAfterSeconds` for the existing countdown instead of the hard-coded 15.

### 3.3 `POST /auth/verify-otp` (public)
Request `{"phone":"9876543210","otp":"4821","name":"Priya Sharma","email":"priya@example.com"}`
- `name` and `email` come from the existing `AuthArgs` (filled on the Sign-up screen). Required for a **new** number; ignored for an existing account. `email` is optional (send `null`/omit if empty).
- Name rules (same as the sign-up form): 2-60 chars, no digits. Email: `x@y.z`, max 254.

Success `data`:
```json
{ "accessToken":"...", "refreshToken":"...", "tokenType":"Bearer", "expiresIn":900,
  "isNewUser":true,
  "user":{ "id":"uuid","name":"Priya Sharma","phone":"9876543210","email":"priya@example.com","createdAt":"..." } }
```
This call **creates the account in PostgreSQL** for a new number. Save both tokens
(section 5), then continue to the Success screen.

### 3.4 `POST /auth/refresh` (public)
Request `{"refreshToken":"..."}` -> same shape as 3.3 (`user` is null). **Replace both stored tokens
every time.** Each refresh token works once; sending an old one returns 401 and kills that login.

### 3.5 `POST /auth/logout` (needs access token)
Request `{"refreshToken":"..."}` -> `{"success":true}`. Safe to call twice. Then clear local tokens
and session whatever the result.

### 3.6 `GET /users/me` (needs access token)
-> `data: { id, name, phone, email, createdAt }`. Use on app start to restore the session.

### 3.7 `GET /catalog/categories` (needs access token) - optional, next step
-> `data: [ {id,title,tagline,price,originalPrice,rating} x8 ]` in display order. Replaces
`DemoServices.categories`; icon/colour/photo stay local, matched by `id`. See `api-contract-m2-catalog.md`.

## 4. Error codes and what to show

| HTTP | `error.code` | Meaning | Suggested UX |
|---|---|---|---|
| 400 | `VALIDATION_FAILED` | bad field, see `details` | show the field message (`details.phone`, `details.name`, `details.email`) |
| 400 | `OTP_INVALID` | wrong OTP, `details.remainingAttempts` | existing red text "Incorrect OTP. Please try again." |
| 400 | `OTP_EXPIRED` | expired, used, or never requested | "OTP expired. Please request a new one." and enable Resend |
| 429 | `OTP_LOCKED` | 5 wrong attempts | "Too many attempts. Request a new OTP." and enable Resend |
| 429 | `RATE_LIMITED` | too many requests, `details.retryAfterSeconds` | "Please try again in N seconds." |
| 401 | `UNAUTHORIZED` | bad/expired token | refresh once, else go to login |
| 403 | `FORBIDDEN` | account blocked | "This account is unavailable." |
| 503 | `SMS_UNAVAILABLE` | SMS not configured | "Could not send OTP. Try again later." |
| none | (network error/timeout) | no connection | "No internet connection. Please try again." |

Keep the current look: the OTP screen already has an error line; for the Login screen use a
SnackBar or the existing style. Never show raw server text for 5xx.

## 5. Changes by file

1. **`core/network/api_client.dart`**
   - Parse the envelope: on `DioException` with a response, build `AppException(error.code, error.message)`; with no response throw `AppException('NETWORK', ...)`.
   - Add the 401 handler (the TODO there): on 401 from a protected call, call `/auth/refresh` **once** (queue concurrent requests behind one refresh), store the new tokens, retry; if refresh fails, clear tokens and send the user to login. Do not add auth headers to the public `/auth/*` calls except logout.
2. **`features/auth/data/auth_repository.dart`**: replace the demo with Dio calls `checkPhone`, `sendOtp`, `verifyOtp`, `refresh`, `logout`, `me` (sketch in section 8). Delete `_demoUsers`.
3. **`login_screen.dart`**: `_proceed()` -> `checkPhone(phone)`; `registered` true -> `Routes.otp` with `AuthArgs(phone: phone)`; false -> `Routes.signup` as now. Catch `AppException`, stop the spinner, show the message. Optional: also require first digit 6-9 so the server never returns `VALIDATION_FAILED`.
4. **`signup_screen.dart`**: no server call. Keep passing name/email in `AuthArgs`.
5. **`otp_screen.dart`**
   - `initState`: call `sendOtp(phone)` once; start the timer from `resendAfterSeconds`. On failure show the error and enable Resend.
   - `_verify()`: call `verifyOtp(phone, otp, name, email)`. On success save tokens + user and `context.go(Routes.success, extra: args-with-server-name)`. Map `OTP_INVALID`/`OTP_EXPIRED`/`OTP_LOCKED`/`RATE_LIMITED` to the existing error text; clear the boxes as today. Remove the `0000` demo rule.
   - `_resend()`: call `sendOtp`.
6. **`success_screen.dart`**: sign in with the **server's** `user` (not local args). Use `isNewUser` for the "Welcome to HerCare, <name>" line (the current `AuthArgs.isNewUser` can stay as fallback).
7. **`core/storage/token_storage.dart`**: already exists; call `save(access:, refresh:)` after verify/refresh and `clear()` on logout/401. Tokens only live in secure storage, never in logs, prefs or `AuthArgs`.
8. **`auth/data/session.dart` + `splash_screen.dart`**: on app start read the stored token; if present call `GET /users/me`; success -> `signIn(name, phone)` and go home; 401 after refresh failure -> login. Keep the 1.8 s splash.
9. **`home_shell.dart` (Log out)**: call `logout(refreshToken)`, then `tokenStorage.clear()`, `signOut()`, go to login (even if the call fails).
10. **Platform config (required, not UI)**
    - `android/app/src/main/AndroidManifest.xml`: add `<uses-permission android:name="android.permission.INTERNET"/>`. Today it only exists in the **debug** manifest, so release builds cannot reach the network.
    - `android/app/src/debug/AndroidManifest.xml`: add `android:usesCleartextTraffic="true"` on `<application>` so debug builds may call `http://` dev servers. Never in release.
    - iOS `Info.plist`: for local dev add `NSAppTransportSecurity` -> `NSAllowsLocalNetworking = true`. Production must be HTTPS with no exception.
    - `env/dev.json`: real phone -> `http://<PC-LAN-IP>:8080/api/v1`. `env/staging.json` and `env/prod.json` must be HTTPS. Run with `flutter run --dart-define-from-file=env/dev.json`.

## 6. Security rules for the app

- Send only what the API lists. Never send a user id; identity comes from the token.
- Tokens only in `flutter_secure_storage`. Never print tokens, OTPs or phone numbers.
- Store the **new** refresh token after every refresh.
- Do not log full request bodies in release builds. Do not hard-code URLs or secrets.
- No client-side OTP check, no demo numbers or codes left in production code.

## 7. Tests to update/add

`test/auth_flow_test.dart` relies on the demo (`9876543210`, `0000`). Override
`authRepositoryProvider` with a fake that returns controlled results, then cover: existing user,
new user + sign-up + OTP, wrong OTP, expired OTP, rate limit, network error, logout, and token
restore on start. Add a repository test with a mocked Dio for envelope and error mapping.

## 8. Sketch (illustrative, adapt to your style)

```dart
class AuthRepository {
  AuthRepository(this._dio);
  final Dio _dio;

  Future<bool> checkPhone(String phone) async =>
      (await _post('/auth/check-phone', {'phone': phone}))['registered'] as bool;

  Future<void> sendOtp(String phone) => _post('/auth/send-otp', {'phone': phone});

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp, {String? name, String? email}) =>
      _post('/auth/verify-otp', {'phone': phone, 'otp': otp, 'name': name, 'email': email}
        ..removeWhere((k, v) => v == null));

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    try {
      final res = await _dio.post(path, data: body);
      return (res.data['data'] as Map?)?.cast<String, dynamic>() ?? {};
    } on DioException catch (e) {
      final err = e.response?.data is Map ? e.response!.data['error'] : null;
      throw AppException(err?['code'] ?? 'NETWORK', err?['message'] ?? 'Could not reach the server');
    }
  }
}
```

## 9. How to test end to end

1. Start the backend (dev profile, local PostgreSQL `helper_app`).
2. Run the app with `env/dev.json`. Enter a new number, fill name/email, continue.
3. Read the OTP from the backend console and type it.
4. Expect the Success screen, then Home showing the real name.
5. In pgAdmin 4: `helper_app` -> Schemas -> public -> Tables -> `users` -> View/Edit Data. Or:
   `select full_name, phone_e164, email, role, created_at from users order by created_at desc;`
   The new row must be there. `otp_challenges` shows the OTP as a 64-character hash, never the code.
6. Log out and log in again with the same number: expect `isNewUser=false`, same name.
7. Also check: wrong OTP (remaining attempts), 5 wrong -> locked, resend inside 15 s -> message, airplane mode -> network message, kill and reopen the app -> still signed in.

## 10. Not done yet on the backend side (production blockers)

- **Real SMS:** needs a provider (for example MSG91/Twilio) and India DLT registration. Until then production `send-otp` returns 503 and dev only prints the OTP in the log.
- **HTTPS** hosting and proxy IP settings for rate limiting.
- OTP is 4 digits because the UI is 4 boxes; 6 digits would be safer later (needs UI + backend change).
