# Coach Web Dashboard Report

## Architecture & Implementation
The Coach Dashboard is built using native Laravel Blade with a Spartan dark aesthetic matching the mobile application's brand identity.

### Route Map
All routes are guarded with `['auth', 'active', 'role:coach']`:

| URI | Method | Controller Action | Description |
|---|---|---|---|
| `/coach/dashboard` | GET | `CoachDashboardController@index` | Key performance indicators, trainee roster preview, programs overview |
| `/coach/trainees` | GET | `CoachDashboardController@trainees` | Paginated roster of assigned trainees with search and status filtering |
| `/coach/trainees/{id}` | GET | `CoachDashboardController@showTrainee` | Trainee deep-dive: physical profile, workout history, assigned programs |
| `/coach/programs` | GET | `CoachDashboardController@programs` | Program catalog with day breakdown and active trainee counter |
| `/coach/exercises` | GET | `CoachDashboardController@exercises` | Exercise catalog with movement instructions and muscle group badges |

---

## Data Isolation & Security
- **Strict Coach-Trainee Boundary:** In `showTrainee()`, access is verified via `CoachTraineeRelationship::where('coach_id', $coach->id)->where('trainee_id', $id)->firstOrFail()`. A coach cannot query or inspect trainees not assigned to them.
- **Role Enforcement:** Unauthenticated users are redirected to `/login`. Trainees attempting access receive a `403 Forbidden` response.
