# P5 - Training, Cardio, Analytics, and Trainee App

All routes are versioned under `/api/v1` and return JSON. Authentication uses Sanctum bearer tokens. Business rules and tenant isolation are enforced server-side; see `AUTHORIZATION.md`.

## 1. Scope Delivered

- Shared exercise library with public and coach-owned private exercises.
- Coach-owned workout programs containing ordered days and exercises.
- Program assignments to trainees with an active coaching relationship.
- Trainee workout sessions and sets with historical performance data.
- Dated cardio records (duration, optional distance, optional average heart rate).
- Date-ranged analytics for trainees and assigned coaches.
- Flutter trainee app surfaces for sign-in, Home, Train, Cardio, Progress, and Settings.
- Centralized dark-first design tokens, EN/AR localization with RTL, and reduced-motion-aware motion.
- Body-measurement history UI built on the P4 `/trainee/progress` API.

P5 does not implement subscriptions, payments, coach/admin dashboards, BMR/calorie calculators, persistent mobile auth, or the AI coach.

## 2. Data Model

| Table | Purpose | Key constraints |
|-------|---------|-----------------|
| `exercises` | Shared/private exercise catalog | Controlled muscle group/equipment enums; coach owns private rows |
| `workout_programs` | Coach-owned program | Coach owner; name length check |
| `workout_program_days` | Weekly day within a program | Unique `(workout_program_id, day_number)`; day 1-7 |
| `workout_day_exercises` | Ordered exercise prescription | Unique `(workout_program_day_id, sort_order)`; rep/set/weight/rest ranges |
| `workout_assignments` | Program assigned to a trainee | One active assignment per program/trainee; `active`/`ended`; valid date range |
| `workout_sessions` | Dated trainee session | Assignment/trainee link; completion cannot precede start |
| `workout_sets` | Performed sets | Unique `(session, exercise, set_number)`; weight/reps ranges |
| `cardio_sessions` | Dated cardio activity | Controlled activity enum; duration/distance/HR ranges |
| `body_measurements` | Dated body measurements (P4) | At-least-one value; documented ranges; history preserved |

`workout_programs` and `exercises` use restrictive deletes where training history must be preserved. Program days and day exercises cascade within their owning program. Trainee deletion cascades that trainee's assignments, sessions, cardio, and measurement records where configured.

## 3. API Surface

### Shared exercise library

| Method | Path | Access | Notes |
|--------|------|--------|-------|
| GET | `/exercises` | Coach or trainee | Paginated; filter by search/muscle group/equipment |
| GET | `/exercises/{exercise}` | Coach or trainee | Public or authorized private exercise only |

Trainees can read public exercises and private exercises referenced by an active assignment whose program coach still has an active relationship with them. Coaches can read public exercises and their own private exercises.

### Coach training management

| Method | Path | Notes |
|--------|------|-------|
| POST | `/coach/exercises` | Create private exercise |
| PATCH | `/coach/exercises/{exercise}` | Owner only |
| DELETE | `/coach/exercises/{exercise}` | Owner only; rejected if referenced by training history |
| GET | `/coach/programs` | Own programs only; paginated |
| POST | `/coach/programs` | Optional nested days/exercises |
| GET | `/coach/programs/{program}` | Owner only |
| PATCH | `/coach/programs/{program}` | Owner only; full schedule replacement blocked after assignment history |
| DELETE | `/coach/programs/{program}` | Owner only; rejected when assignments or history exist |
| POST | `/coach/programs/{program}/assignments` | Owner only; trainee must have an active relationship with this coach |
| GET | `/coach/assignments` | Own programs only; active coaching relationships only |
| POST | `/coach/assignments/{assignment}/end` | Own program and active relationship; sets `status=ended` + `ends_on` |
| GET | `/coach/trainees/{trainee}/workouts` | Active assigned trainee only; nested private data gated |
| GET | `/coach/trainees/{trainee}/workouts/{session}` | Session must belong to path trainee |
| GET | `/coach/trainees/{trainee}/cardio` | Active assigned trainee only |
| GET | `/coach/trainees/{trainee}/cardio/{cardio}` | Record must belong to path trainee |
| GET | `/coach/trainees/{trainee}/analytics` | Active assigned trainee only |

### Trainee training and analytics

| Method | Path | Notes |
|--------|------|-------|
| GET | `/trainee/assignments` | Own assignments; filter status |
| GET | `/trainee/assignments/{assignment}` | Own only (404 otherwise) |
| GET | `/trainee/sessions` | Own history; paginated |
| POST | `/trainee/sessions` | Active relationship + active assignment + date/exercise validation |
| GET | `/trainee/sessions/{session}` | Own only |
| PATCH | `/trainee/sessions/{session}` | Own only; sets replaced transactionally |
| DELETE | `/trainee/sessions/{session}` | Own only; sets cascade |
| GET | `/trainee/cardio` | Own records; filter date range |
| POST | `/trainee/cardio` | Own record; future dates rejected |
| GET | `/trainee/cardio/{cardio}` | Own only |
| PATCH | `/trainee/cardio/{cardio}` | Own only |
| DELETE | `/trainee/cardio/{cardio}` | Own only |
| GET | `/trainee/analytics` | Own range summary; defaults to last 30 days |

`POST /trainee/sessions` accepts session metadata plus `sets[]`. Every set exercise must belong to the assigned program; set numbers must be unique per exercise within the session.

## 4. Validation and Integrity Rules

- Program days are numbered 1-7, unique per program.
- `sort_order` is unique per program day. Repeated `sort_order` values across different days are valid.
- Rep ranges require `target_reps_min <= target_reps_max`.
- Nested program updates reject duplicate days/orders, unknown exercises, and exercises the coach cannot use.
- A program with assignment history cannot have its weekly schedule replaced. Create a new program version instead.
- An assignment cannot start after it ends. Ending an assignment records `ends_on` and is audited.
- Duplicate active assignments for the same program/trainee are rejected by both service checks and a PostgreSQL partial unique index.
- Session creation requires an active coaching relationship, an active assignment covering the session date, and sets limited to that program's exercises.
- Session updates preserve ownership and revalidate all replacement sets.
- Cardio duration, distance, and heart rate are range-checked in requests and PostgreSQL constraints.
- Analytics accepts `from`/`to` (`Y-m-d`), rejects reversed ranges and ranges longer than 366 days, and rejects future `to` dates.

## 5. Authorization and Security Invariants

- All training routes require an active, verified user and the correct role middleware.
- Coaches can manage only exercises/programs they own.
- A coach can assign/end only for trainees with an **active** coaching relationship and only for their own program.
- Trainee/coach training reads require an active relationship and, for trainees, an active assignment. Ending a relationship also ends active assignments belonging to that coach.
- Nested program, assignment, and private-exercise details are omitted when `Gate::allows('view', ...)` fails. A second coach reading a shared trainee's session cannot see another coach's private program or exercise details.
- Cross-tenant scoped resources return **404** where a path resource is requested.
- Super admin is denied trainee/coach training routes by role middleware; future admin tooling must be explicitly authorized and audited.
- Request inputs never set ownership, coach/trainee IDs, or actor identity.
- Mutations are audited with entity identifiers and field names where applicable, never credentials or sensitive health values.

### Relationship termination behavior

Ending an active coach-trainee relationship transactionally:

1. Ends the relationship.
2. Ends that coach's active training assignments for the trainee.
3. Writes relationship and assignment-ending audit entries.

After termination, the trainee can still read historical sessions they own, but coach access and nested private program/exercise data are revoked. Trainees also cannot start new sessions without an active coaching relationship.

## 6. Analytics Semantics

`GET /trainee/analytics` and `GET /coach/trainees/{trainee}/analytics` return:

```json
{
  "from": "2026-10-01",
  "to": "2026-10-30",
  "workouts": {
    "has_data": true,
    "sessions": 4,
    "completed_sessions": 4,
    "sets": 32,
    "completed_sets": 30,
    "reps": 240,
    "volume_kg": 12500.5,
    "weekly": [
      { "week_start": "2026-09-28", "sessions": 2, "completed_sessions": 2, "sets": 16, "completed_sets": 16, "reps": 120, "volume_kg": 6100.0 }
    ]
  },
  "cardio": { "has_data": false, "sessions": 0, "duration_seconds": 0, "distance_km": 0, "weekly": [] },
  "body": { "has_data": true, "series": [] }
}
```

- Weekly buckets start on Monday.
- `volume_kg` uses completed sets: `weight_kg * reps`.
- Missing data is represented by `has_data: false`; zero totals alone are not treated as proof of data.
- Body series is returned only within the requested range and is ordered by measurement date/id.

## 7. Flutter Application

- `lib/core`: API client, bearer auth, exceptions, parsing helpers, app controller/scope.
- `lib/data`: hand-written tolerant models, per-domain repositories, pagination helper.
- `lib/design`: colors, typography, spacing, radii, and themes. Screens reuse tokens/components.
- `lib/components`: shared cards, buttons, fields, loading/error/empty states, charts, Spartan companion.
- `lib/features`: splash/sign-in, shell, Home, Train, Cardio, Progress, Settings.
- `lib/localization`: typed English/Arabic strings and RTL directionality.

The P5 auth bridge intentionally stores the token **in memory only**. Persistent auth/session restoration and full profile/onboarding UX remain P7 work. A stable `AuthGate` owns the splash/sign-in/shell transition so route-stack pushes cannot bypass the signed-in state. Date formatting is initialized for `en`/`ar` at startup; inherited-widget reads occur in `didChangeDependencies`, never `initState`.

Training history supports editing existing sessions and sets through the same logger used for creation. Progress includes derived weight/workout-volume/cardio trends, backend-aligned measurement ranges, today-capped date pickers, and explicit-null updates so cleared measurements are removed. Cardio date/time selection is capped at now.

### Design and motion

- Dark-first premium visual direction using existing logo/splash assets.
- Responsive bottom navigation and wide-window rail.
- Charts stay LTR inside RTL layouts because numeric axes are direction-neutral.
- The Spartan companion is a Flutter `CustomPaint` figure with idle/training/success/milestone states.
- No suitable Rive Spartan character asset exists. No counterfeit asset is used or claimed. The existing Rive/Lottie dependencies are not presented as implemented character content.
- `MediaQuery.disableAnimations` is honored for reduced motion.

## 8. Verification Evidence

Run on 2026-10-28; mobile regression suite re-run on 2026-10-29 (local development environment):

| Command | Result |
|---------|--------|
| `php artisan test` | PASSED - 165 tests, 601 assertions |
| P5 focused backend suite | PASSED - 73 tests, 355 assertions |
| `vendor/bin/phpunit -c phpunit.integration.xml` | PASSED - 28 tests, 39 assertions on isolated PostgreSQL `one_more_rep_test` |
| `vendor/bin/pint --test` | PASSED |
| `php artisan route:list --path=api/v1 --json` | 67 API v1 routes |
| `flutter analyze` | No issues found (re-run 2026-10-29) |
| `flutter test` | 48 tests passed (re-run 2026-10-29) |
| `flutter build web` | PASSED (`build/web`, re-run 2026-10-29) |

PostgreSQL integration tests refuse any driver other than `pgsql` and any database not ending in `_test`. Local test credentials were supplied at runtime from the local `.env`; they were not printed or committed. No development or production database was touched.

## 9. Known Limitations and P6 Boundary

- Rive/Lottie character animation is not implemented because no suitable licensed asset exists.
- Mobile auth is an in-memory sign-in bridge; no registration, profile editing, token refresh, or persistence yet.
- Charts are rendered LTR even in RTL layouts.
- Widget tests use fake repositories; they do not exercise live networking.
- No automated concurrent-request stress test or third-party security audit exists.
- P6 subscriptions, vouchers, and manual payment approval are not started.
