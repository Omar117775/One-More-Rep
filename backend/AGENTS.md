# One More Rep - Backend Rules

## Purpose
This is the Laravel REST API for One More Rep. All business rules must be enforced server-side. Never trust client-supplied roles, IDs, prices, or permissions.

## Technology
- Laravel 13, PHP 8.3+, PostgreSQL
- Laravel Sanctum for API authentication (bearer tokens)
- Eloquent ORM with migrations as source of truth

## Security Requirements
- **Authentication**: Use Sanctum bearer tokens. Tokens expire after 7 days (configurable). Support token revocation (current and all).
- **Authorization**: Use Policies and Gates. Never use blanket super-admin bypasses. Enforce tenant isolation.
- **Roles**: Only `super_admin`, `coach`, `trainee`. Public registration creates trainees only. Coaches/super admins created by authorized means only (CLI or super admin).
- **Tenant Isolation**: Coaches can only access assigned trainees. Trainees can only access their own records. Cross-tenant access returns 404 where appropriate.
- **Validation**: Validate all inputs server-side. Prohibit client-supplied privileged fields.
- **Passwords**: Minimum 10 characters with letters and numbers. Never log passwords/tokens/secrets.
- **Database**: Use migrations only. Never run destructive operations. Use transactions for critical operations.
- **Audit**: Log privileged actions with redacted metadata.

## API Conventions
- Versioned API under `/api/v1`
- JSON responses
- Bearer token auth: `Authorization: Bearer <token>`
- Rate limiting on auth endpoints
- Proper HTTP status codes (401, 403, 404, 422, 429)

## Testing
- SQLite `:memory:` for feature tests with guards
- Separate PostgreSQL integration tests for constraints
- Never use or reset development database
- Never claim tests passed unless actually run
