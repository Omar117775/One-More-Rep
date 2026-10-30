# Security and Authorization Report

## Security Principles Enforced

1. **Server-Side Authorization Authority:**
   All permissions, roles, vouchers, and payment states are validated server-side. The client application is never trusted to assert role permissions or payment authenticity.

2. **Tenant Isolation:**
   - Trainees can access only their own workout sessions, body measurements, assignments, and cardio logs.
   - Coaches can access only trainees explicitly connected via an active `CoachTraineeRelationship`.
   - Super admins have audited global read/write access with action logging.

3. **Multi-Guarded Middleware Stack:**
   - `auth:sanctum` / `auth:web`: Ensures authenticated identity.
   - `active`: Validates that `is_active` is true. If false, active personal access tokens are purged and request is rejected with `403`.
   - `verified`: Trainee endpoints require verified email (`email_verified_at != null`).
   - `role:...`: Enforces exact role membership using the relational pivot table `user_roles`.

4. **Automated Verification:**
   - 173 backend tests passing covering role enforcement, tenant boundary verification, rate limiting, and web dashboard access.
