# One More Rep — Project Plan

## Phase 1: Foundation

- [x] Create the Flutter application.
- [x] Create the Laravel application.
- [x] Configure PostgreSQL connectivity.
- [x] Initialize the Git repository and publish it to GitHub.
- [ ] Document the architecture and development rules.
- [ ] Verify environment configuration and security exclusions.

## Phase 2: Architecture and Data Model

- [ ] Define system requirements and user journeys.
- [ ] Design the ERD and database relationships.
- [ ] Define API conventions and error responses.
- [ ] Define roles, permissions, and coach–trainee isolation.
- [ ] Define the shared design system and localization strategy.

## Phase 3: Authentication and Profiles

- [ ] Registration, login, logout, and email verification.
- [ ] Password reset and secure session/token management.
- [ ] Trainee and coach profiles.
- [ ] Role-based authorization and automated tests.

## Phase 4: Coach and Trainee Management

- [ ] Coach profiles and client assignment.
- [ ] Join requests and approval workflows.
- [ ] Coach-specific client lists and access controls.
- [ ] Trainee progress records.

## Phase 5: Training System

- [ ] Exercise library.
- [ ] Workout programs and weekly schedules.
- [ ] Workout sessions, sets, repetitions, and weights.
- [ ] Historical performance and progress charts.
- [ ] Cardio tracking.
- [ ] Body measurements.

## Phase 6: Subscriptions and Vouchers

- [ ] Backend-managed subscription plans and prices.
- [ ] Coach-specific pricing where required.
- [ ] Voucher generation, validation, expiration, and usage limits.
- [ ] Manual Vodafone Cash payment requests and admin approval.
- [ ] Payment gateway integration after provider verification.
- [ ] Auditable subscription and payment events.

## Phase 7: Trainee Mobile App

- [ ] Authentication and profile setup.
- [ ] Home dashboard and workout experience.
- [ ] Workout history and progress.
- [ ] Cardio, BMR, and estimated calorie tools.
- [ ] Subscription and voucher screens.
- [ ] Localization and accessibility.

## Phase 8: Coach Dashboard

- [ ] Client management.
- [ ] Workout program creation and assignment.
- [ ] Progress reports.
- [ ] Subscription status visibility within authorized scope.

## Phase 9: Super Admin Dashboard

- [ ] User and role management.
- [ ] Subscription plan and pricing management.
- [ ] Voucher management.
- [ ] Manual payment review and approval.
- [ ] Audit logs and platform settings.

## Phase 10: AI Coach

- [ ] Define AI capabilities and safety boundaries.
- [ ] Implement a replaceable AI provider interface.
- [ ] Add retrieval from approved exercise knowledge.
- [ ] Restrict AI context to authorized user data.
- [ ] Evaluate answer quality and safety.

## Phase 11: Quality and Release

- [ ] Automated backend tests.
- [ ] Flutter tests and static analysis.
- [ ] Authorization and data-isolation tests.
- [ ] Payment and voucher edge-case tests.
- [ ] Production configuration, backups, monitoring, and HTTPS.
- [ ] Privacy policy, terms, and store preparation.
- [ ] Staged beta release.

## Delivery Rule

Complete each phase incrementally. Review the design, test the implementation, and update documentation before moving to dependent features.
