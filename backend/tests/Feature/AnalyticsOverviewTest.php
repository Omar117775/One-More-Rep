<?php

namespace Tests\Feature;

use App\Models\BodyMeasurement;
use App\Models\Exercise;
use App\Models\User;
use App\Models\WorkoutAssignment;
use Laravel\Sanctum\Sanctum;
use Tests\Concerns\CreatesTrainingData;
use Tests\Concerns\CreatesUsers;

class AnalyticsOverviewTest extends FeatureTestCase
{
    use CreatesTrainingData;
    use CreatesUsers;

    /**
     * @return array{coach: User, trainee: User, assignment: WorkoutAssignment, exercise: Exercise}
     */
    private function context(): array
    {
        $coach = $this->createCoach();
        $trainee = $this->createTrainee();
        $this->linkCoach($coach, $trainee);
        $program = $this->makeProgram($coach);
        $assignment = $this->makeAssignment($coach, $trainee, $program, [
            'starts_on' => now()->subDays(60)->toDateString(),
            'ends_on' => now()->addDays(5)->toDateString(),
        ]);
        $exercise = $program->days->first()->exercises->first()->exercise;

        return compact('coach', 'trainee', 'assignment', 'exercise');
    }

    public function test_trainee_analytics_aggregates_workouts_cardio_and_body_series(): void
    {
        $context = $this->context();

        $this->makeSession($context['trainee'], $context['assignment'], [
            'started_at' => now()->subDays(10)->setTime(10, 0),
            'completed_at' => now()->subDays(10)->setTime(11, 0),
        ], [
            ['exercise_id' => $context['exercise']->id, 'set_number' => 1, 'weight_kg' => 100, 'reps' => 5, 'is_completed' => true],
            ['exercise_id' => $context['exercise']->id, 'set_number' => 2, 'weight_kg' => 50, 'reps' => 10, 'is_completed' => false],
        ]);

        $this->makeSession($context['trainee'], $context['assignment'], [
            'started_at' => now()->subDays(2)->setTime(18, 0),
            'completed_at' => null,
        ], [
            ['exercise_id' => $context['exercise']->id, 'set_number' => 1, 'weight_kg' => 60, 'reps' => 8, 'is_completed' => true],
        ]);

        $this->makeCardio($context['trainee'], [
            'duration_seconds' => 1800,
            'distance_km' => 5,
            'performed_at' => now()->subDays(5),
        ]);
        $this->makeCardio($context['trainee'], [
            'duration_seconds' => 3600,
            'distance_km' => 10,
            'performed_at' => now()->subDay(),
        ]);

        BodyMeasurement::create([
            'trainee_id' => $context['trainee']->id,
            'weight_kg' => 82.5,
            'measured_on' => now()->subDays(8)->toDateString(),
        ]);
        BodyMeasurement::create([
            'trainee_id' => $context['trainee']->id,
            'body_fat_percentage' => 17.5,
            'waist_cm' => 84,
            'measured_on' => now()->subDays(1)->toDateString(),
        ]);

        Sanctum::actingAs($context['trainee']);

        $response = $this->getJson('/api/v1/trainee/analytics?from='.now()->subDays(30)->toDateString().'&to='.now()->toDateString())
            ->assertStatus(200)
            ->assertJsonPath('data.workouts.has_data', true)
            ->assertJsonPath('data.workouts.sessions', 2)
            ->assertJsonPath('data.workouts.completed_sessions', 1)
            ->assertJsonPath('data.workouts.sets', 3)
            ->assertJsonPath('data.workouts.completed_sets', 2)
            ->assertJsonPath('data.workouts.reps', 13)
            ->assertJsonPath('data.workouts.volume_kg', 980)
            ->assertJsonPath('data.cardio.has_data', true)
            ->assertJsonPath('data.cardio.sessions', 2)
            ->assertJsonPath('data.cardio.duration_seconds', 5400)
            ->assertJsonPath('data.cardio.distance_km', 15)
            ->assertJsonPath('data.body.has_data', true)
            ->assertJsonCount(2, 'data.body.series')
            ->assertJsonPath('data.body.series.0.weight_kg', '82.50')
            ->assertJsonPath('data.body.series.1.weight_kg', null)
            ->assertJsonPath('data.body.series.1.body_fat_percentage', '17.50');

        $weeklyVolume = collect($response->json('data.workouts.weekly'))->sum('volume_kg');
        $this->assertEquals(980, $weeklyVolume);
    }

    public function test_empty_analytics_distinguishes_no_data_from_zero(): void
    {
        $trainee = $this->createTrainee();
        Sanctum::actingAs($trainee);

        $this->getJson('/api/v1/trainee/analytics')
            ->assertStatus(200)
            ->assertJsonPath('data.workouts.has_data', false)
            ->assertJsonPath('data.workouts.sessions', 0)
            ->assertJsonPath('data.workouts.volume_kg', 0)
            ->assertJsonPath('data.workouts.weekly', [])
            ->assertJsonPath('data.cardio.has_data', false)
            ->assertJsonPath('data.cardio.sessions', 0)
            ->assertJsonPath('data.cardio.weekly', [])
            ->assertJsonPath('data.body.has_data', false)
            ->assertJsonPath('data.body.series', []);
    }

    public function test_analytics_validation_rejects_invalid_ranges(): void
    {
        $trainee = $this->createTrainee();
        Sanctum::actingAs($trainee);

        $this->getJson('/api/v1/trainee/analytics?from='.now()->toDateString().'&to='.now()->subDay()->toDateString())
            ->assertStatus(422)
            ->assertJsonValidationErrors('from');

        $this->getJson('/api/v1/trainee/analytics?from='.now()->subDays(400)->toDateString())
            ->assertStatus(422)
            ->assertJsonValidationErrors('from');

        $this->getJson('/api/v1/trainee/analytics?to='.now()->addDay()->toDateString())
            ->assertStatus(422)
            ->assertJsonValidationErrors('to');

        $this->getJson('/api/v1/trainee/analytics?from=not-a-date')
            ->assertStatus(422)
            ->assertJsonValidationErrors('from');
    }

    public function test_default_analytics_range_is_last_thirty_days(): void
    {
        $context = $this->context();
        $this->makeSession($context['trainee'], $context['assignment'], [
            'started_at' => now()->subDays(40),
            'completed_at' => now()->subDays(40),
        ]);
        $recent = $this->makeSession($context['trainee'], $context['assignment'], [
            'started_at' => now()->subDay(),
            'completed_at' => now(),
        ]);

        Sanctum::actingAs($context['trainee']);

        $response = $this->getJson('/api/v1/trainee/analytics')->assertStatus(200);
        $this->assertSame(1, $response->json('data.workouts.sessions'));
        $this->assertSame(now()->subDays(29)->toDateString(), $response->json('data.from'));
        $this->assertSame(now()->toDateString(), $response->json('data.to'));

        $explicit = $this->getJson('/api/v1/trainee/analytics?from='.now()->subDays(60)->toDateString())->assertStatus(200);
        $this->assertSame(2, $explicit->json('data.workouts.sessions'));
    }

    public function test_analytics_are_tenant_isolated(): void
    {
        $context = $this->context();
        $other = $this->createTrainee();
        $otherProgram = $this->makeProgram($context['coach']);
        $otherAssignment = $this->makeAssignment($context['coach'], $other, $otherProgram, [
            'starts_on' => now()->subDays(60)->toDateString(),
            'ends_on' => now()->addDays(5)->toDateString(),
        ]);
        $this->makeSession($other, $otherAssignment, [
            'started_at' => now()->subDay(),
            'completed_at' => now(),
        ]);
        $this->makeCardio($other, ['performed_at' => now()->subDay()]);

        Sanctum::actingAs($context['trainee']);

        $this->getJson('/api/v1/trainee/analytics')
            ->assertStatus(200)
            ->assertJsonPath('data.workouts.has_data', false)
            ->assertJsonPath('data.cardio.has_data', false);
    }

    public function test_coach_reads_analytic_only_for_assigned_trainee(): void
    {
        $context = $this->context();
        $this->makeCardio($context['trainee'], ['performed_at' => now()->subDay()]);
        $unassigned = $this->createTrainee();

        Sanctum::actingAs($context['coach']);

        $this->getJson("/api/v1/coach/trainees/{$context['trainee']->id}/analytics")
            ->assertStatus(200)
            ->assertJsonPath('data.cardio.sessions', 1);

        $this->getJson("/api/v1/coach/trainees/{$unassigned->id}/analytics")
            ->assertStatus(403);
    }

    public function test_ended_relationship_revokes_coach_analytics_access(): void
    {
        $coach = $this->createCoach();
        $trainee = $this->createTrainee();
        $this->linkCoach($coach, $trainee, 'ended');

        Sanctum::actingAs($coach);

        $this->getJson("/api/v1/coach/trainees/{$trainee->id}/analytics")
            ->assertStatus(403);
    }

    public function test_analytics_route_requires_authentication(): void
    {
        $this->getJson('/api/v1/trainee/analytics')->assertStatus(401);
    }
}
