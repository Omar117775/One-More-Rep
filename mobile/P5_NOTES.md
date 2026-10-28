# P5 — Flutter Trainee App (One More Rep)

## Scope delivered
Full trainee mobile app in `D:\FitnessApp\mobile` wired to the Laravel REST API:

- **Auth gate**: `SplashScreen` → sign-in when no token; token kept **in memory only** (no persistent storage, per scope).
- **Shell**: bottom `NavigationBar` with Home / Train / Cardio / Progress / Settings; responsive rail fallback on wide windows.
- **Home**: dashboard with stat tiles, quick actions that switch shell tabs, Spartan companion.
- **Train**: assignments → program detail → sessions (list, details, create/edit session & sets, delete).
- **Cardio**: paginated cardio list, create/edit/delete with client-side form validation.
- **Progress**: paginated measurements, create/edit/delete, weight/body-fat/trends charts (LTR charts inside RTL layouts by design).
- **Analytics**: date-ranged summary from `/trainee/analytics`; Home defaults to the last 30 days.
- **Settings**: language toggle EN/العربية with full RTL support, API base URL editor, sign-out.
- **Spartan companion**: `CustomPaint` figure (no Rive/Lottie assets exist, so none used) with idle/training/success/milestone states; honors reduced-motion.
- **Localization**: typed EN/AR strings in `lib/localization/app_strings.dart`.

## Architecture
- `lib/core` — `ApiClient` (base URL via `String.fromEnvironment('OMR_API_BASE_URL')`, default `http://10.0.2.2:8000/api/v1`), `ApiException`, JSON parsing helpers, `AppController` + `AppScope`.
- `lib/design` — tokens (colors/spacing/typography/radii) + `AppTheme`; no hardcoded styles in screens.
- `lib/components` — shared widgets (cards, buttons, text fields, loading/error/empty states, stat tiles, quick actions, animated line/bar charts, Spartan companion).
- `lib/data` — freezed-style hand-written models with tolerant `fromJson`; repositories per domain with pagination helper (per_page=50, capped at 10 pages).
- Screens stay thin; business rules live in the Laravel backend.

## Verification (run 2026-10-28)
- `flutter analyze` — **No issues found!**
- `flutter test` — **39 passing, 0 failing** (auth repo, model parsing, form validation, home, charts, Spartan companion, RTL/localization).
- `flutter build web` — success (`build/web`); note: `http.Client` is used on real devices only.
- Backend P5 API/security/verification evidence: `../docs/architecture/P5_TRAINING_AND_PROGRESS.md`.

## Known limitations / honest notes
- API base defaults to `10.0.2.2` (Android emulator loopback); change it in Settings or via `--dart-define=OMR_API_BASE_URL=...`.
- Token is in-memory: sign-in is not persisted across app restarts (deliberate per scope; P7 will address persistence).
- Charts are rendered LTR even under RTL locale (accepted; numeric axes are direction-neutral).
- Test HTTP inside widgets is mocked (400) — widget tests use fake repositories, so no real networking is exercised there.
- ApiClient tests that asserted `Authorization` header behavior rely on `http` package middleware; header token is only attached when non-empty.
- Reduced-motion is honored via `MediaQuery.disableAnimations`.
