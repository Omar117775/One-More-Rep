# P4 - Coach and Trainee Management API

All routes are versioned under `/api/v1` and return JSON. Authentication uses Sanctum bearer tokens. Role/tenant rules are enforced server-side; see `AUTHORIZATION.md`.

## 1. Coach Directory

| Method | Path | Access | Notes |
|--------|------|--------|-------|
| GET | `/coaches` | Any authenticated active user | Active + verified coaches only; paginated; excludes email |
| GET | `/coaches/{coach}` | Any authenticated active user | 404 if not an active verified coach |

Response item:

```json
{
  "id": 12,
  "name": "Coach Name",
  "display_name": "Coach Rex",
  "bio": "Strength coach",
  "is_active": true
}
```

## 2. Relationship Lifecycle

Statuses: `pending`, `active`, `rejected`, `cancelled`, `ended`.

Coach-facing trainee list/detail (`/coach/trainees`, `/coach/trainees/{trainee}`) returns only `id`, `name`, and `is_active`. Email, roles, login metadata, and trainee health profiles are intentionally excluded.

| From | To | Actor | Endpoint |
|------|----|-------|----------|
| - | `pending` | Trainee | `POST /trainee/relationships` |
| `pending` | `active` | Addressed coach | `POST /coach/requests/{id}/approve` |
| `pending` | `rejected` | Addressed coach | `POST /coach/requests/{id}/reject` |
| `pending` | `cancelled` | Requesting trainee | `POST /trainee/relationships/{id}/cancel` |
| `active` | `ended` | Coach or trainee participant | `POST /coach/relationships/{id}/end` or `POST /trainee/relationships/{id}/end` |

Rules enforced inside database transactions with row locks:

- Requests are trainee-initiated only; `trainee_id` always comes from the token.
- A coach cannot approve/reject another coach's request; the request is scoped to `coach_id`, so cross-coach access is **404**.
- A trainee cannot cancel/end another trainee's row; scoped to `trainee_id` (**404**).
- Only `pending` rows can be approved/rejected/cancelled; only `active` rows can be ended. Repeated or stale transitions return **422**.
- One `active` row per coach-trainee pair; one `active` primary coach per trainee; one `pending` row per pair; one `pending` primary request per trainee. Conflicts return **422** and are also blocked by partial unique indexes.
- Secondary coaches are allowed alongside an active primary coach.
- Ending a relationship allows a new primary request/approval.
- Self-assignment, non-coach targets, inactive coaches/trainees, and unverified coaches are rejected (**422**).
- Every transition writes an audit log entry without sensitive values.
- Lifecycle writes lock the trainee row before the relationship row so approvals, endings, and new requests for the same trainee serialize consistently. Partial unique indexes remain the final integrity guard; resulting unique violations return **422**.

Representation:

```json
{
  "id": 7,
  "coach_id": 12,
  "trainee_id": 34,
  "relationship_type": "primary",
  "status": "active",
  "started_at": "2026-10-29T10:00:00Z",
  "responded_at": "2026-10-29T10:00:00Z",
  "ended_at": null,
  "coach": { "id": 12, "name": "Coach Name", "display_name": "Coach Rex", "is_active": true },
  "trainee": { "id": 34, "name": "Trainee Name", "is_active": true }
}
```

### Trainee endpoints

| Method | Path | Notes |
|--------|------|-------|
| POST | `/trainee/relationships` | Body: `coach_id` (required), `relationship_type` (`primary` default, or `secondary`) |
| GET | `/trainee/relationships` | Filters: `status`, `relationship_type`, `per_page` |
| GET | `/trainee/relationships/{id}` | Own rows only |
| POST | `/trainee/relationships/{id}/cancel` | Pending only |
| POST | `/trainee/relationships/{id}/end` | Active only |

### Coach endpoints

| Method | Path | Notes |
|--------|------|-------|
| GET | `/coach/requests` | Defaults to `pending`; filter `status`, `per_page` |
| GET | `/coach/requests/{id}` | Addressed to authenticated coach |
| POST | `/coach/requests/{id}/approve` | Pending only |
| POST | `/coach/requests/{id}/reject` | Pending only |
| GET | `/coach/relationships` | Scoped to authenticated coach; filter `status`, `per_page` |
| POST | `/coach/relationships/{id}/end` | Active only |

## 3. Trainee Progress Records

P4 implements the dated `BODY_MEASUREMENTS` model documented in the ERD.

Fields:

| Field | Type | Validation |
|-------|------|------------|
| `measured_on` | date | required; not in the future |
| `weight_kg` | decimal | nullable; 20-500 |
| `body_fat_percentage` | decimal | nullable; 0-100 |
| `waist_cm` | decimal | nullable; 20-300 |
| `chest_cm` | decimal | nullable; 20-300 |
| `arm_cm` | decimal | nullable; 5-150 |

At least one measurement value is required. Records are append-only by convention: later entries do not overwrite earlier history, and multiple entries for the same date are allowed. Owners may correct `measured_on` or individual values through PATCH; every update is audited with field names only.

### Trainee (owner) endpoints

| Method | Path | Notes |
|--------|------|-------|
| GET | `/trainee/progress` | Paginated; newest `measured_on` first |
| POST | `/trainee/progress` | 201; `trainee_id` prohibited |
| GET | `/trainee/progress/{measurement}` | Own only (404 otherwise) |
| PATCH | `/trainee/progress/{measurement}` | Own only; cannot clear all values |
| DELETE | `/trainee/progress/{measurement}` | Own only; 204 |

### Coach (read-only) endpoints

| Method | Path | Notes |
|--------|------|-------|
| GET | `/coach/trainees/{trainee}/progress` | Requires active assignment; paginated |
| GET | `/coach/trainees/{trainee}/progress/{measurement}` | Measurement must belong to the path trainee |

Coaches cannot create, update, or delete progress records (no routes exist; 405). Super admin has no P4 progress route; P9 admin tooling must add explicit, audited access.

## 4. Error semantics

| Status | Meaning |
|--------|---------|
| 401 | Missing/invalid token |
| 403 | Wrong role, inactive/unverified account, or no active assignment |
| 404 | Resource not owned/addressed to the caller, or not found |
| 405 | Method not allowed for that role's progress route |
| 422 | Validation failure, duplicate/conflicting request, or invalid/repeated transition |

## 5. Audit

- `coach_relationship.requested`, `.approved`, `.rejected`, `.cancelled`, `.ended`
- `body_measurement.created`, `.updated`, `.deleted`

Audit metadata contains IDs and changed field names only; measurement values are never stored in audit metadata.

## 6. Out of scope for P4

- Coach-initiated invitations and super-admin direct assignment (P9).
- Workout programs, sessions, performance charts, and cardio (P5).
- Coach dashboard UI (P8) and trainee app screens (P7).
