# One More Rep — API Conventions

## Versioning
- All API routes under `/api/v1/`

## Authentication
- Use Laravel Sanctum tokens via `Authorization: Bearer {token}`
- Protected routes require `auth:sanctum`
- Active users required (`active` middleware), verified for coach/admin (`verified`)

## Authorization
- Role-based via `role:{role}` middleware
- Tenant isolation enforced server-side; never trust client IDs

## Requests/Responses
- JSON requests/responses
- Validation errors return 422 with field errors
- Auth errors: 401 Unauthenticated, 403 Forbidden
- Use API Resources for consistent shapes

## Pagination
- Use pagination for lists; enforce max page size (see PaginationConfig)
- Include pagination metadata

## Rate Limiting
- Apply rate limits to auth, register, password, verification endpoints

## Security
- No secrets in responses/logs
- Server-side enforcement of all business rules
- Nested resources are omitted when the caller cannot view them; do not leak private program/exercise data through shared trainee history
- Cross-tenant scoped path resources return **404** where they exist, not **403**

## Date Ranges and Analytics
- Date filters use `Y-m-d`
- Analytics defaults to the last 30 days when `from`/`to` are omitted
- Reversed ranges, ranges longer than 366 days, and future `to` dates are rejected with **422**
- Analytics summaries include `has_data`; zero totals alone do not prove data exists

## Training Conventions
- Workout program days are numbered 1-7 and unique per program
- Exercise `sort_order` is unique **per program day**, not globally
- Program schedule replacement is rejected after assignment history exists; create a new program version
- Workout-session sets must reference exercises in the assigned program
- Mutations that change training access are audited without sensitive values
