# Super Admin Web Dashboard Report

## Architecture & Implementation
The Super Admin Console provides command-level visibility and management across the entire One More Rep ecosystem.

### Route Map
All routes are guarded with `['auth', 'active', 'role:super_admin']`:

| URI | Method | Controller Action | Description |
|---|---|---|---|
| `/admin/dashboard` | GET | `AdminDashboardController@index` | Global metrics, active subscriptions, recent users, real-time audit logs |
| `/admin/users` | GET | `AdminDashboardController@users` | System-wide user directory with role filtering, status filtering, and search |
| `/admin/users/{id}/toggle-status` | POST | `AdminDashboardController@toggleUserStatus` | Enable/disable user accounts with audit log recording |
| `/admin/subscriptions` | GET | `AdminDashboardController@subscriptions` | Subscription tier monitoring (Monthly, Yearly, Spartan Elite) |
| `/admin/vouchers` | GET | `AdminDashboardController@vouchers` | Voucher code inventory, redemption count, and expiration monitoring |
| `/admin/payments` | GET | `AdminDashboardController@payments` | Pending Vodafone Cash and InstaPay payment reviews |

---

## Audit Logging
Whenever an administrative action is taken (e.g. enabling or disabling an account), an immutable `AuditLog` row is created capturing:
- `user_id` (admin actor)
- `action` (e.g. `user.enabled`, `user.disabled`)
- `auditable_type` and `auditable_id`
- `ip_address`
- `payload` with contextual details
