# HerExpert (HerCare worker app)

The app HerCare experts use to go online, take jobs and see their pay.
Everything runs on mock data; look for `TODO(...)` markers where the backend,
camera, maps, calling and payments plug in.

## Run

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Demo

| What | Value |
|---|---|
| Phone | `9876543210` (existing expert) |
| OTP | `1234` |
| Job start code | `1234` |

Any other 10 digit number goes through sign up (language, details, documents).
Going online brings a sample request after a few seconds.

## Layout

```
lib/
  app/            theme (all colours) and router
  core/utils/     formatting, "today"
  shared/widgets/ common UI, animations, painted artwork
  features/<name>/{data,domain,presentation}
```

Features: auth, onboarding, home, jobs, earnings, shifts, rewards, shop, benefits,
refer, updates, profile, support.

## Not built yet

Real backend calls, camera capture, maps and navigation, phone/chat, SOS
dialling, translations (the language choice is only remembered), persistence
(a restart signs you out), and a production Android signing config.

## iPhone signing

Bundle id `com.hercare.workerApp`. Do not commit your team id to
`project.pbxproj`.
