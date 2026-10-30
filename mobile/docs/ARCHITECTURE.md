# Mobile App Architecture — One More Rep (Trainee App)

Practical rules for contributing to `D:\FitnessApp\mobile`. The app is the
trainee mobile client; all business rules (permissions, prices, program
templates, voucher validity) live in the Laravel backend — the app only
displays and submits data.

## Stack

- Flutter (stable channel) / Dart. Verified with Flutter 3.47.8 / Dart 3.13.7.
- State: hand-rolled `ChangeNotifier` (`AppController`, per-feature view
  models) + an `InheritedWidget` (`AppScope`). No state-management package.
- Networking: `http` (REST JSON, bearer token). No code-gen, no GraphQL.
- Localization: `flutter_localizations` + `intl` + typed EN/AR strings.
- Lints: `flutter_lints` (see `analysis_options.yaml`).

## Folder structure

```
lib/
  main.dart            entry point; initializes intl date data, builds OneMoreRepApp
  app.dart             MaterialApp: theme, delegates, EN/AR locale, AuthGate
  core/                app-wide plumbing
    api_client.dart    JSON REST client + defaultApiBaseUrl (dart-define)
    api_exception.dart typed errors incl. 422 field errors
    app_controller.dart  session/locale state (ChangeNotifier)
    app_scope.dart       InheritedWidget exposing the controller
    formatters.dart    EN/AR-safe date/number formatting
    parsing.dart       tolerant JSON helpers (decimals may arrive as strings)
  data/
    models/            hand-written models with tolerant fromJson
    repositories/      one repository per domain + pagination helper
  design/              DO put style values here
    tokens.dart        AppColors, AppSpacing, AppRadii, AppDurations,
                       AppBreakpoints, AppText (Manrope)
    app_theme.dart     ThemeData built from tokens (dark-first)
  components/          shared widgets: cards, buttons, fields, loading /
                       error / empty states, stat tiles, charts, companion
  features/            one folder per product area, thin screens
     auth/  shell/  splash/  home/  train/  cardio/  progress/  settings/
     library/  programs/   # P5 mock catalogs (see "Mock catalogs" below)
  localization/
    app_strings.dart   typed English/Arabic string pair
```

## Theming rules

- Dark theme is the product look. The single `buildAppTheme()` (dark) is
  applied to `MaterialApp.theme`; a light counterpart `buildLightAppTheme()`
  exists in the same builder (gold/bronze on warm ivory) but is opt-in —
  dark is primary.
- Palette identity: premium black base with metallic **gold** primary
  accents and warm **bronze** secondary accents; grays/ivory for text.
  Never hardcode colors, spacing, radii, durations, font sizes, or breakpoints
  in feature code. Use `lib/design/tokens.dart`.
- Brand marks are drawn in Dart (no image assets): `lib/design/brand/`
  holds `SpartanEmblem` (CustomPaint helmet artwork, `emphasis`-scaled) and
  `AnimatedSpartanMark` (entrance/breath/shimmer motion honoring the
  reduced-motion flag). Use these for logo/identity moments. Shell nav icons
  are also code-drawn: `AnimatedIconSlot(kind:, selected:)` from
  `lib/design/brand/shell_icons.dart` plugs into both `NavigationDestination`
  and `NavigationRailDestination` (`icon:` = outline slot, `selectedIcon:` =
  filled slot; the fresh mount replays the settle bounce).
  - Known viewport breakpoints: `AppBreakpoints.shell` (bottom nav → rail),
    `AppBreakpoints.contentMax` (max content width).
- Shared visual language comes from `lib/components/`; prefer reusing them
  over local one-off widgets.

## Motion system

Single source in `lib/design/motion/`; every widget-level animation reads
`MediaQuery.disableAnimations` and falls back to a static or instant render:

- `AppMotion` — named durations (`fast/medium/slow/emphasis/breathe/shimmer`)
  and curves (`easeOutCubic`, `settle`, `page`, ...). `AppDurations`
  (tokens.dart) remains the canonical duration set; `AppMotion` re-exports
  and adds the rest.
- `AppPageTransitionsBuilder` — premium push transition (rise + fade + scale,
  incoming page); wired into `pageTransitionsTheme` of both theme builders so
  every `MaterialPageRoute` inherits it. Reduced motion → pure fade.
- `PressableScale` — visual press feedback wrapper (scale 0.975) for cards,
  tiles, icons; child gestures keep priority; optional `onTap` for inert
  children. Reduced motion → no scale.
- `CountUpNumber(value:, format:)` — numeric tween; final frame is exactly
  `format(value)` so tests/strings stay deterministic. Reduced motion → final
  value immediately.
- `ProgressRingBar(value:, size:)` — gold→bronze ring sweep over a dim track
  for achievement-style metrics. Reduced motion → instant final sweep.

## Localization & RTL

- Two locales (en / ar). All user-visible strings come from `AppStrings`
  (typed constants, no `.arb` codegen) mapped via `AppStringsScope`.
- Layouts must work mirrored: use `EdgeInsets.symmetric` / logical properties
  instead of `left`/`right`; numeric charts intentionally stay LTR.
- Reduced motion is honored via `MediaQuery.disableAnimations`.

## Mock catalogs (P5)

Two feature-local catalogs are served by clearly-marked local mock data until
the backend ships the corresponding endpoints:

- `features/library/` — `ExerciseRepository` (interface) + `MockExerciseRepository`
  (≈24 exercises, English catalog copy). View model `LibraryViewModel` holds
  search/filter state only. Both screens accept an optional `repository:`
  injection for tests; default is the mock.
- `features/programs/` — `ProgramRepository` + `MockProgramRepository`
  (≈6 programs). Enrollment is explicitly NOT wired: the program detail CTA is
  labeled "Coming soon" and only shows a local snackbar. No pricing,
  subscription or server action is implied from the client.

Entry points: two extra Home quick-action tiles push these screens
(`MaterialPageRoute` → shared `AppPageTransitionsBuilder`); the 5-destination
shell and `AppBreakpoints` logic are untouched. A real backend swap only
touches `MockExerciseRepository` / `MockProgramRepository` (or adds real
implementations in `lib/data/` and passes them into the screens/view models)
— screen and localization layers stay unchanged.

## Configuration & security rules

- API base URL: `--dart-define=OMR_API_BASE_URL=https://.../api/v1`
  (default points at the Android-emulator loopback `10.0.2.2:8000/api/v1`);
  the Settings screen also allows runtime override for local development.
- Auth token is held in memory only (explicit Phase-5 decision; persistence is
  planned later). Never store tokens in plain files or logs.
- Secrets are never stored in the repo. Load environment-specific values only
  through `--dart-define` or gitignored files. `.gitignore` excludes
  `.env*`, `*.key`, and local machine config (`android/local.properties`,
  keystores via `android/.gitignore`).

## Running and checking

```
flutter pub get
flutter run --dart-define=OMR_API_BASE_URL=http://10.0.2.2:8000/api/v1
flutter analyze      # must finish with "No issues found!"
flutter test         # must be all green (48 tests today)
flutter build web    # sanity build; real HTTP calls are device-side
```

## What NOT to do

- Do not add API endpoints, auth checks, pricing, or permission logic in the
  app; the backend owns those decisions.
- Do not introduce new state-management / DI / router packages without an
  approved reason documented here.
- Do not redesign visuals or add hardcoded styles; extend tokens/components.
- Do not commit `.env`, tokens, payment data, or local machine config.
- Do not delete existing files/features without checking references first.
