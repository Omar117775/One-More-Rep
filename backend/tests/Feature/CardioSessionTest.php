<?php

namespace Tests\Feature;

use Laravel\Sanctum\Sanctum;
use Tests\Concerns\CreatesTrainingData;
use Tests\Concerns\CreatesUsers;

class CardioSessionTest extends FeatureTestCase
{
    use CreatesTrainingData;
    use CreatesUsers;

    private function payload(array $overrides = []): array
    {
        return array_merge([
            'activity_type' => 'running',
            'duration_seconds' => 1800,
            'distance_km' => 5.25,
            'average_heart_rate' => 145,
            'performed_at' => now()->subHour()->toIso8601String(),
        ], $overrides);
    }

    public function test_trainee_creates_and_lists_own_cardio_history(): void
    {
        $trainee = $this->createTrainee();
        $other = $this->createTrainee();
        $this->makeCardio($other);
        Sanctum::actingAs($trainee);

        $id = $this->postJson('/api/v1/trainee/cardio', $this->payload())
            ->assertStatus(201)
            ->assertJsonPath('data.activity_type', 'running')
            ->assertJsonPath('data.duration_seconds', 1800)
            ->json('data.id');

        $this->assertDatabaseHas('audit_logs', [
            'action' => 'cardio_session.created',
            'entity_id' => $id,
        ]);

        $response = $this->getJson('/api/v1/trainee/cardio')->assertStatus(200);
        $this->assertCount(1, $response->json('data'));
        $this->assertSame($id, $response->json('data.0.id'));
    }

    public function test_cardio_owner_cannot_be_supplied_by_client(): void
    {
        $trainee = $this->createTrainee();
        $other = $this->createTrainee();
        Sanctum::actingAs($trainee);

        $this->postJson('/api/v1/trainee/cardio', $this->payload(['trainee_id' => $other->id]))
            ->assertStatus(422)
            ->assertJsonValidationErrors('trainee_id');
    }

    public function test_cardio_validation_rejects_invalid_and_future_values(): void
    {
        $trainee = $this->createTrainee();
        Sanctum::actingAs($trainee);

        $this->postJson('/api/v1/trainee/cardio', $this->payload([
            'activity_type' => 'teleporting',
            'duration_seconds' => 0,
            'distance_km' => -1,
            'average_heart_rate' => 300,
            'performed_at' => now()->addDay()->toIso8601String(),
        ]))->assertStatus(422)
            ->assertJsonValidationErrors([
                'activity_type',
                'duration_seconds',
                'distance_km',
                'average_heart_rate',
                'performed_at',
            ]);
    }

    public function test_trainee_updates_and_deletes_own_cardio(): void
    {
        $trainee = $this->createTrainee();
        $cardio = $this->makeCardio($trainee);
        Sanctum::actingAs($trainee);

        $this->patchJson("/api/v1/trainee/cardio/{$cardio->id}", [
            'activity_type' => 'cycling',
            'duration_seconds' => 3600,
            'distance_km' => 20,
            'average_heart_rate' => null,
        ])->assertStatus(200)
            ->assertJsonPath('data.activity_type', 'cycling')
            ->assertJsonPath('data.distance_km', '20.00')
            ->assertJsonPath('data.average_heart_rate', null);

        $this->deleteJson("/api/v1/trainee/cardio/{$cardio->id}")->assertStatus(204);
        $this->assertDatabaseMissing('cardio_sessions', ['id' => $cardio->id]);
        $this->assertDatabaseHas('audit_logs', ['action' => 'cardio_session.deleted']);
    }

    public function test_trainee_cannot_access_another_trainees_cardio(): void
    {
        $trainee = $this->createTrainee();
        $other = $this->createTrainee();
        $cardio = $this->makeCardio($other);
        Sanctum::actingAs($trainee);

        $this->getJson("/api/v1/trainee/cardio/{$cardio->id}")->assertStatus(404);
        $this->patchJson("/api/v1/trainee/cardio/{$cardio->id}", ['duration_seconds' => 60])->assertStatus(404);
        $this->deleteJson("/api/v1/trainee/cardio/{$cardio->id}")->assertStatus(404);
    }

    public function test_cardio_history_can_be_filtered_by_date(): void
    {
        $trainee = $this->createTrainee();
        $old = $this->makeCardio($trainee, ['performed_at' => now()->subDays(40)]);
        $recent = $this->makeCardio($trainee, ['performed_at' => now()->subDay()]);
        Sanctum::actingAs($trainee);

        $response = $this->getJson('/api/v1/trainee/cardio?from='.now()->subDays(7)->toDateString())->assertStatus(200);
        $this->assertSame([$recent->id], collect($response->json('data'))->pluck('id')->all());

        $this->getJson('/api/v1/trainee/cardio?from='.now()->toDateString().'&to='.now()->subDay()->toDateString())
            ->assertStatus(422)
            ->assertJsonValidationErrors('from');

        $this->getJson('/api/v1/trainee/cardio?from='.now()->subDays(400)->toDateString())
            ->assertStatus(422)
            ->assertJsonValidationErrors('from');

        $this->getJson('/api/v1/trainee/cardio?to='.now()->addDay()->toDateString())
            ->assertStatus(422)
            ->assertJsonValidationErrors('to');
    }

    public function test_coach_reads_only_assigned_trainee_cardio(): void
    {
        $coach = $this->createCoach();
        $trainee = $this->createTrainee();
        $this->linkCoach($coach, $trainee);
        $cardio = $this->makeCardio($trainee);
        $unassigned = $this->createTrainee();
        $hidden = $this->makeCardio($unassigned);

        Sanctum::actingAs($coach);

        $this->getJson("/api/v1/coach/trainees/{$trainee->id}/cardio")
            ->assertStatus(200)
            ->assertJsonPath('data.0.id', $cardio->id);
        $this->getJson("/api/v1/coach/trainees/{$trainee->id}/cardio/{$cardio->id}")
            ->assertStatus(200);
        $this->getJson("/api/v1/coach/trainees/{$trainee->id}/cardio/{$hidden->id}")
            ->assertStatus(404);
        $this->getJson("/api/v1/coach/trainees/{$unassigned->id}/cardio")
            ->assertStatus(403);
    }

    public function test_ended_relationship_revokes_coach_cardio_access(): void
    {
        $coach = $this->createCoach();
        $trainee = $this->createTrainee();
        $this->linkCoach($coach, $trainee, 'ended');
        $cardio = $this->makeCardio($trainee);

        Sanctum::actingAs($coach);

        $this->getJson("/api/v1/coach/trainees/{$trainee->id}/cardio/{$cardio->id}")
            ->assertStatus(403);
    }
}
