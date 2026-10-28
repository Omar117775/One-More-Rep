# One More Rep — System Requirements and User Journeys

## System Requirements
- Premium fitness platform for international users (Flutter trainee app, Laravel REST API, coach dashboard, super admin dashboard)
- PostgreSQL database, Laravel backend, Flutter mobile
- Roles: super_admin, coach, trainee with strict tenant isolation
- Business rules enforced server-side (prices, permissions, subscriptions, vouchers)
- Manual Vodafone Cash payments require payment reference and explicit admin approval
- AI Coach behind replaceable interface (Ollama locally), context restricted to authorized data
- RTL/LTR support, dark-first premium design

## User Journeys
### Trainee
1. Register/login, verify email, complete profile
2. View assigned coach/workouts, track sessions/sets/reps/weights, cardio, body measurements
3. View progress/history, use BMR/calorie tools
4. Subscribe via plans/vouchers, submit manual payment if applicable

### Coach
1. Manage assigned trainees only
2. Create/assign workout programs, track progress
3. View subscription status within authorized scope

### Super Admin
1. Manage users/roles
2. Manage subscription plans/pricing
3. Manage vouchers
4. Review/approve manual payments
5. View audit logs, platform settings
