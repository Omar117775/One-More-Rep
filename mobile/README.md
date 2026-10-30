# One More Rep — Mobile (Trainee App)

Flutter client for the One More Rep premium fitness platform, built against
the Laravel REST API (`../backend`). Dark-first premium UI, English/Arabic
(EN + RTL). Architecture and conventions: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

## Requirements

- Flutter (stable) — verified with Flutter 3.47.8 / Dart 3.13.7
- A running Laravel backend for real data (`../backend`); the app defaults the
  API base URL to the Android emulator loopback `http://10.0.2.2:8000/api/v1`.

## Run

```bash
flutter pub get
# device/emulator uses its own loopback: point at your local API host
flutter run --dart-define=OMR_API_BASE_URL=http://10.0.2.2:8000/api/v1
```

- The API base URL can also be changed later in the Settings screen.
- Language (EN/العربية) switches live in Settings; RTL layouts are supported.

## Checks

```bash
flutter analyze   # must report "No issues found!"
flutter test      # unit + widget tests must all pass
```

## Notes

- Never commit secrets (`.env*`, keys, tokens) — excluded by `.gitignore`;
  pass configuration via `--dart-define` instead.
- The bearer token is held in memory only (session-scoped by design).
