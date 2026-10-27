# One More Rep — AI Development Rules

## Project Overview
One More Rep is a premium fitness platform for international users. It includes a Flutter trainee app, a Laravel REST API, a coach dashboard, and a super admin dashboard.

## Technology Stack
- Mobile: Flutter and Dart.
- Backend: Laravel REST API with PHP.
- Database: PostgreSQL.
- Local AI development: Ollama, behind a replaceable AI service abstraction.
- Git: All project work must be committed in small, meaningful changes.

## Architecture Rules
- Keep the mobile app, backend, and future coach/admin dashboards separated by clear boundaries.
- Use a modular, maintainable architecture. Avoid oversized files and duplicated business logic.
- Keep business rules in the backend; never rely on Flutter to enforce prices, permissions, subscriptions, or voucher validity.
- Use database migrations for schema changes. Never change production schema manually.
- Design API contracts explicitly and validate inputs on the server.
- Use environment variables for secrets and environment-specific configuration.
- Never commit `.env` files, credentials, API keys, access tokens, private keys, or real user data.

## Roles and Tenant Isolation
- Supported roles: `super_admin`, `coach`, and `trainee`.
- A coach can access only trainees explicitly assigned to that coach.
- A trainee can access only their own private records.
- Super admin permissions must be explicitly authorized and audited.
- Never trust a role, coach ID, trainee ID, price, or subscription status supplied by the client without server-side verification.
- Add authorization tests for every sensitive endpoint.

## Fitness Domain
- Support exercise libraries, workout programs, workout sessions, sets, repetitions, weights, and session dates.
- Track cardio separately with appropriate duration and distance fields.
- Store body measurements and progress as dated records rather than overwriting history.
- Calculate BMR and estimated daily energy expenditure using documented formulas and units.
- AI recommendations must be clearly distinguished from verified measurements and calculations.

## Subscriptions and Vouchers
- Subscription plans, prices, durations, discounts, and voucher rules are controlled by the backend.
- Voucher codes must be unique, validated server-side, and protected against repeated or concurrent redemption.
- Record payment verification, voucher issuance, redemption, expiration, and administrative changes.
- Manual Vodafone Cash payments require a recorded payment reference and explicit admin approval.
- Never treat a WhatsApp message or client-side success screen as proof of payment.
- Never store card numbers or CVV values.

## Security and Privacy
- Validate and authorize every request.
- Use Laravel's established authentication, password hashing, validation, and authorization mechanisms.
- Do not log passwords, tokens, payment secrets, or sensitive personal information.
- Use rate limiting for authentication and voucher endpoints.
- Collect only necessary personal and fitness data.
- Keep AI context restricted to data the current user is authorized to access.

## UI and Design System
- Brand: One More Rep.
- Visual direction: premium, professional, dark-first, internationally usable.
- Centralize colors, typography, spacing, radii, and component styles in reusable theme/design tokens.
- Avoid hardcoded styles repeated across screens.
- Support responsive layouts and Arabic RTL alongside English LTR.
- New features must reuse existing components and design tokens.
- Do not perform broad visual redesigns without an explicit requirement.

## Development Workflow
1. Inspect existing code and project conventions before editing.
2. Explain the intended change briefly before substantial implementation.
3. Make small, focused changes.
4. Run relevant tests, static analysis, and formatting after changes.
5. Report exactly what changed and which checks passed or failed.
6. Never claim a test passed unless it was actually run.
7. Do not delete existing work or overwrite user changes without permission.
8. Do not install new dependencies unless they are needed and their purpose is clear.
9. Update documentation when architecture, setup, or API behavior changes.

## Git Rules
- Keep commits focused and descriptive.
- Never commit secrets, generated build output, dependencies, or local machine configuration.
- Review `git status` and staged changes before committing.
- Do not force-push or rewrite shared history without explicit approval.

## Current Scope
The initial Laravel and Flutter projects exist. First verify their configuration, document the architecture, and design the database model before implementing domain features. Do not generate the entire application in one pass.
