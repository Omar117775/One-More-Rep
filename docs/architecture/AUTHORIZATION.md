# One More Rep - Authorization Policy

All authorization is enforced server-side (middleware, gates, policies, scoped queries). Client-supplied roles/IDs are never trusted. Public registration creates **trainee** accounts only.

## Endpoint / Role Matrix

| Endpoint | super_admin | coach | trainee | Notes |
|----------|-------------|-------|---------|-------|
| `GET /api/v1/health` | public | public | public | No auth |
| `POST /api/v1/auth/register` | public | public | public | Creates trainee only; role fields prohibited |
| `POST /api/v1/auth/login` | public | public | public | Rate limited; inactive users rejected |
| `POST /api/v1/auth/forgot-password` | public | public | public | Generic response (no enumeration) |
| `POST /api/v1/auth/reset-password` | public | public | public | Revokes all tokens on success |
| `GET /api/v1/auth/email/verify/{id}/{hash}` | self | self | self | Signed URL + `auth:sanctum` |
| `GET /api/v1/auth/me` | self | self | self | `auth:sanctum`, `active` |
| `POST /api/v1/auth/logout` | self | self | self | Revokes current token |
| `POST /api/v1/auth/logout-all` | self | self | self | Revokes all tokens |
| `POST /api/v1/auth/email/verification-notification` | self | self | self | Rate limited |
| `GET /api/v1/profile` | self | self | self | Own profile only |
| `PATCH /api/v1/profile` | self | self | self | Own profile only; privilege fields prohibited |
| `GET /api/v1/coach/trainees` | denied | assigned only | denied | Coach routes are coach-only; paginated |
| `GET /api/v1/coach/trainees/{trainee}` | denied | assigned active trainees only | denied | Gate `access-trainee` |
| `GET /api/v1/coaches` | allowed | allowed | allowed | Any authenticated active user; non-sensitive coach summary only |
| `GET /api/v1/coaches/{coach}` | allowed | allowed | allowed | Active + verified coach accounts only |
| `POST /api/v1/trainee/relationships` | denied | denied | self only | Trainee-initiated join request; coach/role/status fields prohibited |
| `GET /api/v1/trainee/relationships` | denied | denied | own only | Paginated, filterable |
| `GET /api/v1/trainee/relationships/{relationship}` | denied | denied | own only | Other trainee's row returns 404 |
| `POST /api/v1/trainee/relationships/{relationship}/cancel` | denied | denied | own pending only | Repeated/invalid transitions return 422 |
| `POST /api/v1/trainee/relationships/{relationship}/end` | denied | denied | own active only | Ends relationship and that coach's active training assignments |
| `GET /api/v1/coach/requests` | denied | addressed to self | denied | Defaults to `pending`; paginated |
| `GET /api/v1/coach/requests/{relationship}` | denied | addressed to self | denied | Other coach's request returns 404 |
| `POST /api/v1/coach/requests/{relationship}/approve` | denied | addressed to self + pending | denied | Transactional; conflicts return 422 |
| `POST /api/v1/coach/requests/{relationship}/reject` | denied | addressed to self + pending | denied | Transactional |
| `GET /api/v1/coach/relationships` | denied | own only | denied | Scoped to authenticated coach |
| `POST /api/v1/coach/relationships/{relationship}/end` | denied | own active only | denied | Other coach's row returns 404; ends this coach's active training assignments |
| `GET /api/v1/trainee/progress` | denied | denied | own only | Dated body-measurement records |
| `POST /api/v1/trainee/progress` | denied | denied | self only | `trainee_id` prohibited |
| `GET/PATCH/DELETE /api/v1/trainee/progress/{measurement}` | denied | denied | own only | Other trainee's record returns 404 |
| `GET /api/v1/coach/trainees/{trainee}/progress` | denied | assigned active only | denied | Read-only; Gate `access-trainee` |
| `GET /api/v1/coach/trainees/{trainee}/progress/{measurement}` | denied | assigned active only | denied | Measurement must belong to the path trainee |
| `GET /api/v1/admin/users` | allowed | denied | denied | `role:super_admin` + `UserPolicy@viewAny` |
| `GET /api/v1/admin/audit-logs` | allowed | denied | denied | `role:super_admin` + `AuditLogPolicy@viewAny` |

### P5 training endpoints

| Endpoint | super_admin | coach | trainee | Notes |
|----------|-------------|-------|---------|-------|
| `GET /api/v1/exercises` | denied | own + public | public + assigned private | Role middleware; active-assignment visibility |
| `GET /api/v1/exercises/{exercise}` | denied | own + public | public + assigned private | Cross-coach private exercise returns 403 |
| `POST/PATCH/DELETE /api/v1/coach/exercises...` | denied | owner only | denied | Delete rejected when referenced by history |
| `GET /api/v1/coach/programs` | denied | own only | denied | Paginated, owner-scoped |
| `POST/PATCH/DELETE /api/v1/coach/programs...` | denied | owner only | denied | Schedule replacement blocked after assignment history |
| `POST /api/v1/coach/programs/{program}/assignments` | denied | own program + active relationship | denied | Duplicate active assignment rejected |
| `GET /api/v1/coach/assignments` | denied | own programs + active relationships | denied | Former assignments hidden |
| `POST /api/v1/coach/assignments/{assignment}/end` | denied | own program + active relationship | denied | Cross-coach/former assignment returns 404 |
| `GET /api/v1/coach/trainees/{trainee}/workouts...` | denied | assigned active only | denied | Nested private program/exercise data gated |
| `GET /api/v1/coach/trainees/{trainee}/cardio...` | denied | assigned active only | denied | Record must belong to path trainee |
| `GET /api/v1/coach/trainees/{trainee}/analytics` | denied | assigned active only | denied | Date-ranged; same range validation as trainee |
| `GET /api/v1/trainee/assignments...` | denied | denied | own only | Other assignment returns 404 |
| `GET/POST/PATCH/DELETE /api/v1/trainee/sessions...` | denied | denied | own only | Requires active relationship + active assignment |
| `GET/POST/PATCH/DELETE /api/v1/trainee/cardio...` | denied | denied | own only | Future dates rejected |
| `GET /api/v1/trainee/analytics` | denied | denied | own only | Defaults to last 30 days |

Super admin is deliberately excluded from P5 coach/trainee training routes by `role:` middleware. Future support/administration tooling for training data belongs to P9 and must be explicitly authorized and audited.

## Tenant Isolation Rules
- Coach listing uses `whereHas` on active `coach_trainee_relationships` scoped to the authenticated coach.
- Coach detail uses `Gate::authorize('access-trainee', $trainee)` which requires: active target user, trainee role, and an active coaching relationship (super admin allowed by gate as defense-in-depth, but coach routes remain coach-only).
- Non-trainee targets and inactive trainees are denied.
- Profile endpoints are self-scoped; no ID parameters exist, eliminating IDOR via path traversal.
- Relationship and progress resources are fetched through scoped queries (`trainee_id` or `coach_id`), so another user's row returns **404**, not 403, to avoid existence disclosure.
- Coach progress reads require an **active** relationship; ended relationships immediately lose access.
- Coach-facing trainee list/detail uses `TraineeSummaryResource` (`id`, `name`, `is_active` only), avoiding email, roles, login metadata, and health-profile leakage.
- Super admin has no P4 trainee/coach route access (role middleware) and no body-measurement access by policy. Admin assignment/progress tooling belongs to P9 and must be audited when added.
- Coach program/assignment access is scoped to the authenticated coach's own programs and an **active** coaching relationship. Former assignments are hidden (**404**), not just read-only.
- Trainee private-exercise visibility requires both an active assignment and an active relationship with that program's coach. An ended relationship revokes private program/exercise access even if a stale assignment row still says `active`.
- Coach reads of a shared trainee's workout sessions gate every nested program, assignment, and private exercise. A second coach cannot see another coach's private programming through the trainee's history.
- Workout-session creation requires an active relationship, an active assignment, a session date within the assignment window, and sets limited to that program's exercises.
- Ending a coaching relationship transactionally ends that coach's active training assignments for the trainee and writes audit entries.

## Assignment Safety
- `role`, `roles`, `is_active`, `is_super_admin`, `email_verified_at`, `user_id`, `password`, `email` are prohibited on self-service profile updates and on registration where applicable.
- Email changes are intentionally out of scope for P3 (would require re-verification).
- Relationship requests prohibit `trainee_id`, `status`, `started_at`, `responded_at`, `ended_at`, `role`, and `roles`; the trainee identity always comes from the authenticated token.
- Progress records prohibit `trainee_id`, `user_id`, and `id`; the owner always comes from the authenticated token.
- Program exercises prohibit client-supplied exercise visibility/ownership. Trainee session and cardio requests prohibit `trainee_id`/`user_id`; ownership always comes from the token.
- Assignment and relationship writes prohibit client-supplied coach/trainee identity, actor identity, and status transitions outside the service layer.
- State transitions are validated inside transactions with row locks; repeated or conflicting transitions return **422** and create no audit record.
- Relationship lifecycle transitions are audited (`coach_relationship.requested/approved/rejected/cancelled/ended`); progress mutations are audited with field names only, never measurement values.
- Training mutations are audited with entity identifiers and structural field names; credentials, payment data, and sensitive health values are never written to audit metadata.

## Training Lifecycle and Revocation

- A relationship ending ends all active assignments owned by that coach for the trainee in the same transaction.
- Trainees retain read access to their own historical sessions but lose access to nested private program/exercise data after an assignment or relationship ends.
- Coaches lose trainee workout/cardio/analytics access immediately when the relationship ends.
- Programs with assignment history cannot have their schedule replaced or be deleted; create a new program version to preserve historical meaning.
- Sort-order uniqueness is per program day. Repeated order values across different days are valid.
