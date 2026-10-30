# Mobile API Integration & Network Architecture Report

## Overview
The Flutter mobile application communicates with the Laravel REST API (`/api/v1`) using bearer-token authentication via Laravel Sanctum.

---

## 1. Network Foundation & Platform-Aware Base URL

### Base URL Resolution Strategy
`ApiClient` resolves its base URL using the following precedence:
1. Compile-time `--dart-define=OMR_API_BASE_URL=...` override.
2. Runtime platform detection:
   - **Flutter Web:** `http://127.0.0.1:8000/api/v1`
   - **Android Emulator:** `http://10.0.2.2:8000/api/v1` (host loopback alias)
   - **Physical Device:** Pass computer's LAN IP via `--dart-define`

### Clean Trainee UI
Internal API configuration fields and "Advanced" URL inputs have been completely removed from:
- `SignInScreen`
- `SettingsScreen`
Trainees interact purely with brand-authentic authentication and settings options.

---

## 2. Authentication & Session Persistence

- **Session Restoration:** On app cold-start, `AuthGate` initiates a non-blocking `tryRestoreSession()` using `SharedPreferences`. Valid tokens automatically restore the active session and load the latest profile via `GET /api/v1/auth/me`.
- **Registration Integration:** `RegistrationScreen` executes `POST /api/v1/auth/register` with `name`, `email`, `password`, and `password_confirmation`, persisting the issued token and initializing the trainee profile.
- **Sign Out:** `signOut()` calls `POST /api/v1/auth/logout`, clears local storage, and resets in-memory state.

---

## 3. Verified Endpoints & PostgreSQL Integration

Tested against PostgreSQL database:
- `POST /api/v1/auth/login` → 200 OK with Bearer Token & User Resource
- `POST /api/v1/auth/register` → 201 Created with Bearer Token
- `GET /api/v1/auth/me` → 200 OK
- `GET /api/v1/trainee/assignments` → 200 OK returning active program and day exercises
- `GET /api/v1/exercises` → 200 OK returning public exercise catalog
