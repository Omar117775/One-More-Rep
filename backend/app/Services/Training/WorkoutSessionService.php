<?php

namespace App\Services\Training;

use App\Enums\Enums\AuditAction;
use App\Enums\Enums\RelationshipStatus;
use App\Enums\Enums\WorkoutAssignmentStatus;
use App\Models\User;
use App\Models\WorkoutAssignment;
use App\Models\WorkoutSession;
use App\Services\Audit\AuditLogger;
use Carbon\CarbonImmutable;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class WorkoutSessionService
{
    public function __construct(private readonly AuditLogger $auditLogger) {}

    public function create(User $trainee, array $data): WorkoutSession
    {
        return DB::transaction(function () use ($trainee, $data) {
            $assignment = WorkoutAssignment::query()
                ->with('program.days.exercises')
                ->lockForUpdate()
                ->find($data['assignment_id']);

            if (! $assignment || $assignment->trainee_id !== $trainee->id) {
                throw ValidationException::withMessages([
                    'assignment_id' => 'The selected assignment is not available.',
                ]);
            }

            if ($assignment->status !== WorkoutAssignmentStatus::ACTIVE) {
                throw ValidationException::withMessages([
                    'assignment_id' => 'Only active assignments can receive new sessions.',
                ]);
            }

            if (! $assignment->program?->is_active) {
                throw ValidationException::withMessages([
                    'assignment_id' => 'The assigned program is inactive.',
                ]);
            }

            $stillCoached = $trainee->traineeRelationships()
                ->where('coach_id', $assignment->program->coach_id)
                ->where('status', RelationshipStatus::ACTIVE)
                ->whereNull('ended_at')
                ->exists();

            if (! $stillCoached) {
                throw ValidationException::withMessages([
                    'assignment_id' => 'The coaching relationship for this assignment is no longer active.',
                ]);
            }

            $startedAt = CarbonImmutable::parse($data['started_at']);
            $this->assertWithinAssignment($assignment, $startedAt);

            $allowedExerciseIds = $this->allowedExerciseIds($assignment);
            $this->assertSetsUseProgramExercises($data['sets'], $allowedExerciseIds);

            $session = WorkoutSession::create([
                'workout_assignment_id' => $assignment->id,
                'trainee_id' => $trainee->id,
                'started_at' => $startedAt,
                'completed_at' => isset($data['completed_at']) ? CarbonImmutable::parse($data['completed_at']) : null,
                'notes' => $data['notes'] ?? null,
            ]);

            $this->replaceSets($session, $data['sets']);

            $this->auditLogger->log($trainee, AuditAction::WORKOUT_SESSION_CREATED->value, $session, [
                'workout_assignment_id' => $assignment->id,
                'set_count' => count($data['sets']),
            ]);

            return $this->loadSession($session);
        }, 3);
    }

    public function update(User $trainee, WorkoutSession $session, array $data): WorkoutSession
    {
        return DB::transaction(function () use ($trainee, $session, $data) {
            $locked = WorkoutSession::query()
                ->with('assignment.program.days.exercises')
                ->lockForUpdate()
                ->findOrFail($session->id);

            if ($locked->trainee_id !== $trainee->id) {
                throw ValidationException::withMessages(['session' => 'This session is not available.']);
            }

            $assignment = $locked->assignment;

            if (! $assignment) {
                throw ValidationException::withMessages(['session' => 'This session has no assignment.']);
            }

            $startedAt = array_key_exists('started_at', $data)
                ? CarbonImmutable::parse($data['started_at'])
                : CarbonImmutable::parse($locked->started_at);

            $this->assertWithinAssignment($assignment, $startedAt);

            $completedAt = array_key_exists('completed_at', $data)
                ? ($data['completed_at'] !== null ? CarbonImmutable::parse($data['completed_at']) : null)
                : $locked->completed_at;

            if ($completedAt !== null && $completedAt->lt($startedAt)) {
                throw ValidationException::withMessages([
                    'completed_at' => 'The completion time must be after the start time.',
                ]);
            }

            if (array_key_exists('sets', $data)) {
                $allowedExerciseIds = $this->allowedExerciseIds($assignment);
                $this->assertSetsUseProgramExercises($data['sets'], $allowedExerciseIds);
            }

            $locked->update([
                'started_at' => $startedAt,
                'completed_at' => $completedAt,
                'notes' => array_key_exists('notes', $data) ? $data['notes'] : $locked->notes,
            ]);

            if (array_key_exists('sets', $data)) {
                $locked->sets()->delete();
                $this->replaceSets($locked, $data['sets']);
            }

            $this->auditLogger->log($trainee, AuditAction::WORKOUT_SESSION_UPDATED->value, $locked, [
                'workout_assignment_id' => $locked->workout_assignment_id,
                'fields' => array_keys($data),
            ]);

            return $this->loadSession($locked);
        }, 3);
    }

    public function delete(User $trainee, WorkoutSession $session): void
    {
        DB::transaction(function () use ($trainee, $session) {
            $locked = WorkoutSession::query()->lockForUpdate()->findOrFail($session->id);

            if ($locked->trainee_id !== $trainee->id) {
                throw ValidationException::withMessages(['session' => 'This session is not available.']);
            }

            $this->auditLogger->log($trainee, AuditAction::WORKOUT_SESSION_DELETED->value, $locked, [
                'workout_assignment_id' => $locked->workout_assignment_id,
            ]);

            $locked->delete();
        }, 3);
    }

    private function assertWithinAssignment(WorkoutAssignment $assignment, CarbonImmutable $startedAt): void
    {
        $date = $startedAt->toDateString();

        if ($date < $assignment->starts_on->toDateString()) {
            throw ValidationException::withMessages([
                'started_at' => 'The session cannot start before the assignment begins.',
            ]);
        }

        if ($assignment->ends_on !== null && $date > $assignment->ends_on->toDateString()) {
            throw ValidationException::withMessages([
                'started_at' => 'The session cannot start after the assignment ends.',
            ]);
        }
    }

    /**
     * @return list<int>
     */
    private function allowedExerciseIds(WorkoutAssignment $assignment): array
    {
        return $assignment->program->days
            ->flatMap(fn ($day) => $day->exercises->pluck('exercise_id'))
            ->map(fn ($id) => (int) $id)
            ->unique()
            ->values()
            ->all();
    }

    private function assertSetsUseProgramExercises(array $sets, array $allowedExerciseIds): void
    {
        foreach ($sets as $index => $set) {
            if (! in_array((int) $set['exercise_id'], $allowedExerciseIds, true)) {
                throw ValidationException::withMessages([
                    "sets.{$index}.exercise_id" => 'This exercise is not part of the assigned program.',
                ]);
            }
        }
    }

    private function replaceSets(WorkoutSession $session, array $sets): void
    {
        foreach ($sets as $set) {
            $session->sets()->create([
                'exercise_id' => $set['exercise_id'],
                'set_number' => $set['set_number'],
                'weight_kg' => $set['weight_kg'] ?? null,
                'reps' => $set['reps'],
                'is_completed' => $set['is_completed'] ?? true,
            ]);
        }
    }

    private function loadSession(WorkoutSession $session): WorkoutSession
    {
        return $session->fresh()->load([
            'sets.exercise',
            'assignment.program.days.exercises.exercise',
        ]);
    }
}
