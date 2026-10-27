# One More Rep

One More Rep is a premium fitness platform designed to help trainees track their training progress while enabling coaches to manage their own clients.

## Applications
- **Trainee App:** Flutter mobile application.
- **Backend API:** Laravel REST API.
- **Database:** PostgreSQL.
- **Coach Dashboard:** Coach-specific client and training management.
- **Super Admin Dashboard:** Platform users, subscriptions, pricing, vouchers, and administration.
- **AI Coach:** A replaceable AI service for fitness-related assistance.

## Core Features
- User registration and authentication.
- Coach–trainee relationships with strict access isolation.
- Exercise library and customizable workout programs.
- Workout history, weights, repetitions, and progress tracking.
- Cardio and body measurement tracking.
- BMR and estimated calorie calculations.
- Subscription plans, voucher codes, and payment records.
- AI-assisted fitness guidance.

## Repository Structure

```text
one-more-rep/
├── backend/   # Laravel API
├── mobile/    # Flutter application
├── AGENTS.md
├── PROJECT_PLAN.md
└── README.md
```

## Development Principles
- Enforce authorization and business rules on the backend.
- Keep credentials and environment files out of Git.
- Use database migrations for schema changes.
- Test critical authorization, subscription, and voucher workflows.
- Reuse a centralized design system.

## Status
Initial project setup. Architecture and database design are the next milestones.
