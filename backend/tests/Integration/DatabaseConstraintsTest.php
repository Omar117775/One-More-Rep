<?php

namespace Tests\Integration;

use App\Models\BodyMeasurement;
use App\Models\CoachTraineeRelationship;
use App\Models\TraineeProfile;
use App\Models\User;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class DatabaseConstraintsTest extends IntegrationTestCase
{
    private function makeUser(string $email): User
    {
        return User::factory()->create([
            'email' => $email,
            'email_verified_at' => now(),
            'is_active' => true,
        ]);
    }

    public function test_users_email_is_unique_case_insensitively(): void
    {
        $this->makeUser('Mixed.Case@Example.com');

        $this->expectException(QueryException::class);

        $this->makeUser('mixed.case@example.com');
    }

    public function test_active_coach_trainee_pair_is_unique(): void
    {
        $coach = $this->makeUser('coach-pair@example.com');
        $trainee = $this->makeUser('trainee-pair@example.com');

        CoachTraineeRelationship::create([
            'coach_id' => $coach->id,
            'trainee_id' => $trainee->id,
            'relationship_type' => 'secondary',
            'status' => 'active',
            'started_at' => now(),
        ]);

        $this->expectException(QueryException::class);

        CoachTraineeRelationship::create([
            'coach_id' => $coach->id,
            'trainee_id' => $trainee->id,
            'relationship_type' => 'secondary',
            'status' => 'active',
            'started_at' => now(),
        ]);
    }

    public function test_only_one_active_primary_relationship_per_trainee(): void
    {
        $coachA = $this->makeUser('coach-a@example.com');
        $coachB = $this->makeUser('coach-b@example.com');
        $trainee = $this->makeUser('trainee-primary@example.com');

        CoachTraineeRelationship::create([
            'coach_id' => $coachA->id,
            'trainee_id' => $trainee->id,
            'relationship_type' => 'primary',
            'status' => 'active',
            'started_at' => now(),
        ]);

        $this->expectException(QueryException::class);

        CoachTraineeRelationship::create([
            'coach_id' => $coachB->id,
            'trainee_id' => $trainee->id,
            'relationship_type' => 'primary',
            'status' => 'active',
            'started_at' => now(),
        ]);
    }

    public function test_ended_relationship_allows_new_active_primary(): void
    {
        $coachA = $this->makeUser('coach-ended-a@example.com');
        $coachB = $this->makeUser('coach-ended-b@example.com');
        $trainee = $this->makeUser('trainee-ended@example.com');

        CoachTraineeRelationship::create([
            'coach_id' => $coachA->id,
            'trainee_id' => $trainee->id,
            'relationship_type' => 'primary',
            'status' => 'ended',
            'started_at' => now()->subMonth(),
            'ended_at' => now(),
        ]);

        $relationship = CoachTraineeRelationship::create([
            'coach_id' => $coachB->id,
            'trainee_id' => $trainee->id,
            'relationship_type' => 'primary',
            'status' => 'active',
            'started_at' => now(),
        ]);

        $this->assertDatabaseHas('coach_trainee_relationships', ['id' => $relationship->id, 'status' => 'active']);
    }

    public function test_deleting_coach_cascades_relationships(): void
    {
        $coach = $this->makeUser('coach-cascade@example.com');
        $trainee = $this->makeUser('trainee-cascade@example.com');

        CoachTraineeRelationship::create([
            'coach_id' => $coach->id,
            'trainee_id' => $trainee->id,
            'relationship_type' => 'primary',
            'status' => 'active',
            'started_at' => now(),
        ]);

        $this->assertSame(1, DB::table('coach_trainee_relationships')->count());

        $coach->delete();

        $this->assertSame(0, DB::table('coach_trainee_relationships')->count());
        $this->assertDatabaseHas('users', ['id' => $trainee->id]);
    }

    public function test_pending_join_request_pair_is_unique(): void
    {
        $coach = $this->makeUser('coach-pending-pair@example.com');
        $trainee = $this->makeUser('trainee-pending-pair@example.com');

        CoachTraineeRelationship::create([
            'coach_id' => $coach->id,
            'trainee_id' => $trainee->id,
            'relationship_type' => 'primary',
            'status' => 'pending',
        ]);

        $this->expectException(QueryException::class);

        CoachTraineeRelationship::create([
            'coach_id' => $coach->id,
            'trainee_id' => $trainee->id,
            'relationship_type' => 'primary',
            'status' => 'pending',
        ]);
    }

    public function test_only_one_pending_primary_request_per_trainee(): void
    {
        $coachA = $this->makeUser('coach-pending-primary-a@example.com');
        $coachB = $this->makeUser('coach-pending-primary-b@example.com');
        $trainee = $this->makeUser('trainee-pending-primary@example.com');

        CoachTraineeRelationship::create([
            'coach_id' => $coachA->id,
            'trainee_id' => $trainee->id,
            'relationship_type' => 'primary',
            'status' => 'pending',
        ]);

        $this->expectException(QueryException::class);

        CoachTraineeRelationship::create([
            'coach_id' => $coachB->id,
            'trainee_id' => $trainee->id,
            'relationship_type' => 'primary',
            'status' => 'pending',
        ]);
    }

    public function test_invalid_relationship_status_is_rejected(): void
    {
        $coach = $this->makeUser('coach-invalid-status@example.com');
        $trainee = $this->makeUser('trainee-invalid-status@example.com');

        $this->expectException(QueryException::class);

        DB::table('coach_trainee_relationships')->insert([
            'coach_id' => $coach->id,
            'trainee_id' => $trainee->id,
            'relationship_type' => 'primary',
            'status' => 'archived',
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    public function test_pending_request_cannot_have_lifecycle_timestamps(): void
    {
        $coach = $this->makeUser('coach-pending-time@example.com');
        $trainee = $this->makeUser('trainee-pending-time@example.com');

        $this->expectException(QueryException::class);

        CoachTraineeRelationship::create([
            'coach_id' => $coach->id,
            'trainee_id' => $trainee->id,
            'relationship_type' => 'primary',
            'status' => 'pending',
            'started_at' => now(),
        ]);
    }

    public function test_active_relationship_requires_started_at(): void
    {
        $coach = $this->makeUser('coach-active-time@example.com');
        $trainee = $this->makeUser('trainee-active-time@example.com');

        $this->expectException(QueryException::class);

        CoachTraineeRelationship::create([
            'coach_id' => $coach->id,
            'trainee_id' => $trainee->id,
            'relationship_type' => 'primary',
            'status' => 'active',
        ]);
    }

    public function test_body_measurement_requires_at_least_one_value(): void
    {
        $trainee = $this->makeUser('trainee-empty-measurement@example.com');

        $this->expectException(QueryException::class);

        BodyMeasurement::create([
            'trainee_id' => $trainee->id,
            'measured_on' => now()->toDateString(),
        ]);
    }

    public function test_body_measurement_range_constraints_are_enforced(): void
    {
        $trainee = $this->makeUser('trainee-range-measurement@example.com');

        $this->expectException(QueryException::class);

        BodyMeasurement::create([
            'trainee_id' => $trainee->id,
            'weight_kg' => 900,
            'measured_on' => now()->toDateString(),
        ]);
    }

    public function test_body_measurement_body_fat_constraint_is_enforced(): void
    {
        $trainee = $this->makeUser('trainee-fat-measurement@example.com');

        $this->expectException(QueryException::class);

        BodyMeasurement::create([
            'trainee_id' => $trainee->id,
            'body_fat_percentage' => 101,
            'measured_on' => now()->toDateString(),
        ]);
    }

    public function test_body_measurements_cascade_when_trainee_is_deleted(): void
    {
        $trainee = $this->makeUser('trainee-measurement-cascade@example.com');

        BodyMeasurement::create([
            'trainee_id' => $trainee->id,
            'weight_kg' => 80,
            'measured_on' => now()->toDateString(),
        ]);

        $this->assertSame(1, DB::table('body_measurements')->count());

        $trainee->delete();

        $this->assertSame(0, DB::table('body_measurements')->count());
    }

    public function test_trainee_profile_sex_values_match_api_validation(): void
    {
        $trainee = $this->makeUser('trainee-sex-allowed@example.com');
        TraineeProfile::create(['user_id' => $trainee->id, 'sex' => 'prefer_not_to_say']);

        $this->assertDatabaseHas('trainee_profiles', ['user_id' => $trainee->id, 'sex' => 'prefer_not_to_say']);

        $other = $this->makeUser('trainee-sex-denied@example.com');

        $this->expectException(QueryException::class);

        TraineeProfile::create(['user_id' => $other->id, 'sex' => 'undisclosed']);
    }
}
