# Development Ecosystem & Test Accounts

## Overview
One More Rep is initialized with an idempotent database seeder (`Database\Seeders\DevTestAccountSeeder`) providing pre-configured accounts for all three user tiers: Trainee, Coach, and Super Admin.

---

## 1. Credentials Matrix

| Role | Email | Password | Access Interface | Verified | Active |
|---|---|---|---|---|---|
| **Trainee** | `test@gmail.com` | `test 1234` | Flutter Mobile App / API | Yes | Yes |
| **Coach** | `coach@onemorerep.fit` | `coach 1234` | Laravel Web Portal (`/coach`) | Yes | Yes |
| **Super Admin** | `admin@onemorerep.fit` | `admin 1234` | Laravel Web Console (`/admin`) | Yes | Yes |

---

## 2. Seeded Domain Data

### Trainee: `test@gmail.com`
- **Name:** Test Trainee
- **Profile:** Male, 178 cm, 82.50 kg, DOB: 1995-06-15
- **Assigned Coach:** Coach Leonidas (`coach@onemorerep.fit`)
- **Relationship:** Primary coaching relationship, Active
- **Active Program:** Spartan Strength Foundation (60-day active assignment)

### Coach: `coach@onemorerep.fit`
- **Name:** Coach Leonidas
- **Bio:** Elite hypertrophy & strength coach. 12+ years building athletic physiques.
- **Authored Programs:**
  - *Spartan Strength Foundation* (3-day split: Push, Pull, Legs & Core)
- **Authored Exercises:**
  - Barbell Bench Press, Incline Dumbbell Press, Overhead Press, Pull-Up, Barbell Row, Biceps Curl, Back Squat, Romanian Deadlift, Hanging Leg Raise

### Super Admin: `admin@onemorerep.fit`
- **Name:** Super Admin
- **Permissions:** Global analytics, full user activation toggling, audit trails, subscription plan management, voucher reviews, manual payment approvals (Vodafone Cash / InstaPay)

---

## 3. Re-running the Seeder

To seed or refresh accounts idempotently without resetting other tables:
```bash
php artisan db:seed --class=DevTestAccountSeeder
```
*Note: Never run `migrate:fresh` or drop database tables.*
