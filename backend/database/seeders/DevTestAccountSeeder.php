<?php

namespace Database\Seeders;

use App\Enums\Enums\WorkoutAssignmentStatus;
use App\Models\CoachProfile;
use App\Models\CoachTraineeRelationship;
use App\Models\Exercise;
use App\Models\Role;
use App\Models\TraineeProfile;
use App\Models\User;
use App\Models\WorkoutAssignment;
use App\Models\WorkoutDayExercise;
use App\Models\WorkoutProgram;
use App\Models\WorkoutProgramDay;
use Illuminate\Database\Seeder;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Hash;

/**
 * Idempotent seeder for the complete One More Rep development ecosystem:
 *
 * 1. Trainee: test@gmail.com / test 1234
 * 2. Coach:   coach@onemorerep.fit / coach 1234
 * 3. Admin:   admin@onemorerep.fit / admin 1234
 *
 * Plus:
 * - Active coaching relationship between Coach & Trainee
 * - Exercise catalog with standard barbell & bodyweight lifts
 * - Structured 3-day Spartan Strength Foundation program
 * - Active program assignment to Test Trainee
 */
class DevTestAccountSeeder extends Seeder
{
    public function run(): void
    {
        $now = Carbon::now();

        // Ensure base roles exist
        $superAdminRole = Role::firstOrCreate(['name' => 'super_admin']);
        $coachRole = Role::firstOrCreate(['name' => 'coach']);
        $traineeRole = Role::firstOrCreate(['name' => 'trainee']);

        // ---------------------------------------------------------------------
        // 1. Super Admin Account
        // ---------------------------------------------------------------------
        $admin = User::firstOrCreate(
            ['email' => 'admin@onemorerep.fit'],
            [
                'name' => 'Super Admin',
                'password' => Hash::make('admin 1234'),
                'locale' => 'en',
                'timezone' => 'Africa/Cairo',
                'is_active' => true,
                'email_verified_at' => $now,
            ]
        );
        $admin->roles()->syncWithoutDetaching([$superAdminRole->id]);

        // ---------------------------------------------------------------------
        // 2. Coach Account
        // ---------------------------------------------------------------------
        $coach = User::firstOrCreate(
            ['email' => 'coach@onemorerep.fit'],
            [
                'name' => 'Coach Leonidas',
                'password' => Hash::make('coach 1234'),
                'locale' => 'en',
                'timezone' => 'Africa/Cairo',
                'is_active' => true,
                'email_verified_at' => $now,
            ]
        );
        $coach->roles()->syncWithoutDetaching([$coachRole->id]);

        CoachProfile::firstOrCreate(
            ['user_id' => $coach->id],
            [
                'display_name' => 'Leonidas of Sparta',
                'bio' => 'Elite hypertrophy & strength coach. 12+ years building athletic physiques.',
                'is_active' => true,
            ]
        );

        // ---------------------------------------------------------------------
        // 3. Trainee Account
        // ---------------------------------------------------------------------
        $trainee = User::firstOrCreate(
            ['email' => 'test@gmail.com'],
            [
                'name' => 'Test Trainee',
                'password' => Hash::make('test 1234'),
                'locale' => 'en',
                'timezone' => 'Africa/Cairo',
                'is_active' => true,
                'email_verified_at' => $now,
            ]
        );
        $trainee->roles()->syncWithoutDetaching([$traineeRole->id]);

        TraineeProfile::firstOrCreate(
            ['user_id' => $trainee->id],
            [
                'date_of_birth' => Carbon::parse('1995-06-15'),
                'sex' => 'male',
                'height_cm' => 178.00,
                'initial_weight_kg' => 82.50,
            ]
        );

        // ---------------------------------------------------------------------
        // 4. Coaching Relationship (Coach -> Trainee)
        // ---------------------------------------------------------------------
        CoachTraineeRelationship::firstOrCreate(
            [
                'coach_id' => $coach->id,
                'trainee_id' => $trainee->id,
            ],
            [
                'relationship_type' => 'primary',
                'status' => 'active',
                'started_at' => $now->copy()->subDays(30),
            ]
        );

        // ---------------------------------------------------------------------
        // 5. Exercise Catalog (Public + Coach created)
        // ---------------------------------------------------------------------
        $exercisesData = [
            [
                'name' => 'Barbell Bench Press',
                'muscle_group' => 'chest',
                'equipment' => 'barbell',
                'instructions' => 'Retract scapula, lower bar to mid-chest, press upwards explosively.',
                'is_public' => true,
            ],
            [
                'name' => 'Incline Dumbbell Press',
                'muscle_group' => 'chest',
                'equipment' => 'dumbbell',
                'instructions' => 'Set bench to 30 degrees, flare elbows 45 degrees, full stretch at bottom.',
                'is_public' => true,
            ],
            [
                'name' => 'Barbell Back Squat',
                'muscle_group' => 'legs',
                'equipment' => 'barbell',
                'instructions' => 'Brace core, break at hips and knees simultaneously, descend below parallel.',
                'is_public' => true,
            ],
            [
                'name' => 'Romanian Deadlift',
                'muscle_group' => 'legs',
                'equipment' => 'barbell',
                'instructions' => 'Hinge at hips with soft knees, feel deep hamstring stretch, drive hips forward.',
                'is_public' => true,
            ],
            [
                'name' => 'Overhead Barbell Press',
                'muscle_group' => 'shoulders',
                'equipment' => 'barbell',
                'instructions' => 'Stand tall, squeeze glutes, press overhead in straight vertical bar path.',
                'is_public' => true,
            ],
            [
                'name' => 'Pull-Up',
                'muscle_group' => 'back',
                'equipment' => 'bodyweight',
                'instructions' => 'Pronated grip, pull chest to bar, controlled descent into full dead hang.',
                'is_public' => true,
            ],
            [
                'name' => 'Barbell Bent-Over Row',
                'muscle_group' => 'back',
                'equipment' => 'barbell',
                'instructions' => '45 degree torso angle, pull bar towards belly button, squeeze lats.',
                'is_public' => true,
            ],
            [
                'name' => 'Barbell Biceps Curl',
                'muscle_group' => 'biceps',
                'equipment' => 'barbell',
                'instructions' => 'Keep elbows pinned to sides, curl barbell without swinging torso.',
                'is_public' => true,
            ],
            [
                'name' => 'Hanging Leg Raise',
                'muscle_group' => 'core',
                'equipment' => 'bodyweight',
                'instructions' => 'Hang from bar, raise legs until parallel to floor or higher without swinging.',
                'is_public' => true,
            ],
        ];

        $exercises = [];
        foreach ($exercisesData as $item) {
            $exercises[$item['name']] = Exercise::firstOrCreate(
                ['name' => $item['name']],
                array_merge($item, ['created_by' => $coach->id])
            );
        }

        // ---------------------------------------------------------------------
        // 6. Workout Program: "Spartan Strength Foundation"
        // ---------------------------------------------------------------------
        $program = WorkoutProgram::firstOrCreate(
            [
                'coach_id' => $coach->id,
                'name' => 'Spartan Strength Foundation',
            ],
            [
                'description' => 'A proven 3-day push/pull/legs protocol designed for progressive overload and muscle hypertrophy.',
                'is_active' => true,
            ]
        );

        // Day 1: Push Day
        $day1 = WorkoutProgramDay::firstOrCreate(
            [
                'workout_program_id' => $program->id,
                'day_number' => 1,
            ],
            [
                'name' => 'Push Focus — Upper Strength',
            ]
        );

        if ($day1->exercises()->count() === 0) {
            WorkoutDayExercise::create([
                'workout_program_day_id' => $day1->id,
                'exercise_id' => $exercises['Barbell Bench Press']->id,
                'sort_order' => 1,
                'target_sets' => 4,
                'target_reps_min' => 6,
                'target_reps_max' => 8,
                'target_weight_kg' => 85.00,
                'rest_seconds' => 120,
            ]);
            WorkoutDayExercise::create([
                'workout_program_day_id' => $day1->id,
                'exercise_id' => $exercises['Incline Dumbbell Press']->id,
                'sort_order' => 2,
                'target_sets' => 3,
                'target_reps_min' => 8,
                'target_reps_max' => 10,
                'target_weight_kg' => 30.00,
                'rest_seconds' => 90,
            ]);
            WorkoutDayExercise::create([
                'workout_program_day_id' => $day1->id,
                'exercise_id' => $exercises['Overhead Barbell Press']->id,
                'sort_order' => 3,
                'target_sets' => 3,
                'target_reps_min' => 8,
                'target_reps_max' => 10,
                'target_weight_kg' => 50.00,
                'rest_seconds' => 90,
            ]);
        }

        // Day 2: Pull Day
        $day2 = WorkoutProgramDay::firstOrCreate(
            [
                'workout_program_id' => $program->id,
                'day_number' => 2,
            ],
            [
                'name' => 'Pull Focus — Back & Biceps',
            ]
        );

        if ($day2->exercises()->count() === 0) {
            WorkoutDayExercise::create([
                'workout_program_day_id' => $day2->id,
                'exercise_id' => $exercises['Pull-Up']->id,
                'sort_order' => 1,
                'target_sets' => 4,
                'target_reps_min' => 8,
                'target_reps_max' => 10,
                'target_weight_kg' => 0.00,
                'rest_seconds' => 120,
            ]);
            WorkoutDayExercise::create([
                'workout_program_day_id' => $day2->id,
                'exercise_id' => $exercises['Barbell Bent-Over Row']->id,
                'sort_order' => 2,
                'target_sets' => 4,
                'target_reps_min' => 8,
                'target_reps_max' => 10,
                'target_weight_kg' => 70.00,
                'rest_seconds' => 90,
            ]);
            WorkoutDayExercise::create([
                'workout_program_day_id' => $day2->id,
                'exercise_id' => $exercises['Barbell Biceps Curl']->id,
                'sort_order' => 3,
                'target_sets' => 3,
                'target_reps_min' => 10,
                'target_reps_max' => 12,
                'target_weight_kg' => 35.00,
                'rest_seconds' => 60,
            ]);
        }

        // Day 3: Legs & Core
        $day3 = WorkoutProgramDay::firstOrCreate(
            [
                'workout_program_id' => $program->id,
                'day_number' => 3,
            ],
            [
                'name' => 'Legs & Core — Lower Power',
            ]
        );

        if ($day3->exercises()->count() === 0) {
            WorkoutDayExercise::create([
                'workout_program_day_id' => $day3->id,
                'exercise_id' => $exercises['Barbell Back Squat']->id,
                'sort_order' => 1,
                'target_sets' => 4,
                'target_reps_min' => 6,
                'target_reps_max' => 8,
                'target_weight_kg' => 110.00,
                'rest_seconds' => 150,
            ]);
            WorkoutDayExercise::create([
                'workout_program_day_id' => $day3->id,
                'exercise_id' => $exercises['Romanian Deadlift']->id,
                'sort_order' => 2,
                'target_sets' => 3,
                'target_reps_min' => 8,
                'target_reps_max' => 10,
                'target_weight_kg' => 95.00,
                'rest_seconds' => 120,
            ]);
            WorkoutDayExercise::create([
                'workout_program_day_id' => $day3->id,
                'exercise_id' => $exercises['Hanging Leg Raise']->id,
                'sort_order' => 3,
                'target_sets' => 3,
                'target_reps_min' => 12,
                'target_reps_max' => 15,
                'target_weight_kg' => 0.00,
                'rest_seconds' => 60,
            ]);
        }

        // ---------------------------------------------------------------------
        // 7. Active Workout Assignment for Test Trainee
        // ---------------------------------------------------------------------
        WorkoutAssignment::firstOrCreate(
            [
                'workout_program_id' => $program->id,
                'trainee_id' => $trainee->id,
                'assigned_by' => $coach->id,
            ],
            [
                'starts_on' => $now->copy()->subDays(7)->toDateString(),
                'ends_on' => $now->copy()->addDays(53)->toDateString(),
                'status' => WorkoutAssignmentStatus::ACTIVE,
            ]
        );

        $this->command->info("Dev ecosystem seeded successfully:");
        $this->command->info("  - Trainee: test@gmail.com / test 1234 (Assigned: Spartan Strength Foundation)");
        $this->command->info("  - Coach:   coach@onemorerep.fit / coach 1234");
        $this->command->info("  - Admin:   admin@onemorerep.fit / admin 1234");
    }
}
