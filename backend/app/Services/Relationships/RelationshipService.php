<?php

namespace App\Services\Relationships;

use App\Enums\Enums\AuditAction;
use App\Enums\Enums\RelationshipStatus;
use App\Enums\Enums\RelationshipType;
use App\Models\CoachTraineeRelationship;
use App\Models\User;
use App\Services\Audit\AuditLogger;
use App\Services\Training\WorkoutProgramService;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class RelationshipService
{
    public function __construct(
        private readonly AuditLogger $auditLogger,
        private readonly WorkoutProgramService $programs,
    ) {}

    public function request(User $trainee, int $coachId, RelationshipType $type): CoachTraineeRelationship
    {
        if (! $trainee->isTrainee()) {
            throw new AuthorizationException('Forbidden.');
        }

        $coach = User::query()->find($coachId);

        if (! $coach || ! $coach->isCoach() || ! $coach->is_active || $coach->email_verified_at === null) {
            throw ValidationException::withMessages([
                'coach_id' => 'The selected coach is not available.',
            ]);
        }

        if ($coach->id === $trainee->id) {
            throw ValidationException::withMessages([
                'coach_id' => 'A user cannot request themselves as a coach.',
            ]);
        }

        try {
            return DB::transaction(function () use ($trainee, $coach, $type) {
                $this->lockTrainee($trainee->id);

                $this->assertNoConflictingRequest($trainee->id, $coach->id, $type);

                $relationship = CoachTraineeRelationship::create([
                    'coach_id' => $coach->id,
                    'trainee_id' => $trainee->id,
                    'relationship_type' => $type,
                    'status' => RelationshipStatus::PENDING,
                ]);

                $this->auditLogger->log($trainee, AuditAction::COACH_RELATIONSHIP_REQUESTED->value, $relationship, [
                    'coach_id' => $coach->id,
                    'trainee_id' => $trainee->id,
                    'relationship_type' => $type->value,
                    'status' => RelationshipStatus::PENDING->value,
                ]);

                return $relationship->fresh();
            }, 3);
        } catch (QueryException $exception) {
            $this->rethrowUniqueViolation($exception);

            throw $exception;
        }
    }

    public function approve(User $coach, CoachTraineeRelationship $relationship): CoachTraineeRelationship
    {
        try {
            return DB::transaction(function () use ($coach, $relationship) {
                $trainee = $this->lockTrainee($relationship->trainee_id);
                $locked = $this->lockRelationship($relationship);
                $this->assertCoachActor($coach, $locked);
                $this->assertPending($locked);

                if (! $trainee->is_active || ! $trainee->isTrainee()) {
                    throw ValidationException::withMessages([
                        'trainee_id' => 'The trainee is no longer eligible for assignment.',
                    ]);
                }

                if (! $coach->is_active || ! $coach->isCoach()) {
                    throw ValidationException::withMessages([
                        'coach_id' => 'The coach is no longer eligible for assignment.',
                    ]);
                }

                if ($this->activePairExists($locked->coach_id, $locked->trainee_id, $locked->id)) {
                    throw ValidationException::withMessages([
                        'status' => 'An active assignment already exists for this coach and trainee.',
                    ]);
                }

                if ($locked->isPrimary() && $this->activePrimaryExists($locked->trainee_id, $locked->id)) {
                    throw ValidationException::withMessages([
                        'status' => 'The trainee already has an active primary coach.',
                    ]);
                }

                $locked->update([
                    'status' => RelationshipStatus::ACTIVE,
                    'started_at' => now(),
                    'responded_at' => now(),
                    'ended_at' => null,
                ]);

                $this->auditLogger->log($coach, AuditAction::COACH_RELATIONSHIP_APPROVED->value, $locked, [
                    'coach_id' => $locked->coach_id,
                    'trainee_id' => $locked->trainee_id,
                    'relationship_type' => $locked->relationship_type?->value,
                    'status' => RelationshipStatus::ACTIVE->value,
                ]);

                return $locked->fresh();
            }, 3);
        } catch (QueryException $exception) {
            $this->rethrowUniqueViolation($exception);

            throw $exception;
        }
    }

    public function reject(User $coach, CoachTraineeRelationship $relationship): CoachTraineeRelationship
    {
        return DB::transaction(function () use ($coach, $relationship) {
            $this->lockTrainee($relationship->trainee_id);
            $locked = $this->lockRelationship($relationship);
            $this->assertCoachActor($coach, $locked);
            $this->assertPending($locked);

            $locked->update([
                'status' => RelationshipStatus::REJECTED,
                'responded_at' => now(),
                'ended_at' => now(),
            ]);

            $this->auditLogger->log($coach, AuditAction::COACH_RELATIONSHIP_REJECTED->value, $locked, [
                'coach_id' => $locked->coach_id,
                'trainee_id' => $locked->trainee_id,
                'relationship_type' => $locked->relationship_type?->value,
                'status' => RelationshipStatus::REJECTED->value,
            ]);

            return $locked->fresh();
        }, 3);
    }

    public function cancel(User $trainee, CoachTraineeRelationship $relationship): CoachTraineeRelationship
    {
        return DB::transaction(function () use ($trainee, $relationship) {
            $this->lockTrainee($relationship->trainee_id);
            $locked = $this->lockRelationship($relationship);
            $this->assertTraineeActor($trainee, $locked);
            $this->assertPending($locked);

            $locked->update([
                'status' => RelationshipStatus::CANCELLED,
                'responded_at' => null,
                'ended_at' => now(),
            ]);

            $this->auditLogger->log($trainee, AuditAction::COACH_RELATIONSHIP_CANCELLED->value, $locked, [
                'coach_id' => $locked->coach_id,
                'trainee_id' => $locked->trainee_id,
                'relationship_type' => $locked->relationship_type?->value,
                'status' => RelationshipStatus::CANCELLED->value,
            ]);

            return $locked->fresh();
        }, 3);
    }

    public function end(User $actor, CoachTraineeRelationship $relationship): CoachTraineeRelationship
    {
        return DB::transaction(function () use ($actor, $relationship) {
            $this->lockTrainee($relationship->trainee_id);
            $locked = $this->lockRelationship($relationship);

            if (! in_array($actor->id, [$locked->coach_id, $locked->trainee_id], true)) {
                throw new AuthorizationException('Forbidden.');
            }

            if (! $locked->isActive()) {
                throw ValidationException::withMessages([
                    'status' => 'Only active assignments can be ended.',
                ]);
            }

            $locked->update([
                'status' => RelationshipStatus::ENDED,
                'ended_at' => now(),
            ]);

            $this->programs->endActiveForRelationship($actor, $locked->coach_id, $locked->trainee_id);

            $this->auditLogger->log($actor, AuditAction::COACH_RELATIONSHIP_ENDED->value, $locked, [
                'coach_id' => $locked->coach_id,
                'trainee_id' => $locked->trainee_id,
                'relationship_type' => $locked->relationship_type?->value,
                'status' => RelationshipStatus::ENDED->value,
            ]);

            return $locked->fresh();
        }, 3);
    }

    private function lockTrainee(int $traineeId): User
    {
        // Lock ordering is trainee -> relationship so lifecycle races serialize.
        return User::query()
            ->whereKey($traineeId)
            ->lockForUpdate()
            ->firstOrFail();
    }

    private function lockRelationship(CoachTraineeRelationship $relationship): CoachTraineeRelationship
    {
        return CoachTraineeRelationship::query()
            ->whereKey($relationship->getKey())
            ->lockForUpdate()
            ->firstOrFail();
    }

    private function assertCoachActor(User $coach, CoachTraineeRelationship $relationship): void
    {
        if (! $coach->isCoach() || $coach->id !== $relationship->coach_id) {
            throw new AuthorizationException('Forbidden.');
        }
    }

    private function assertTraineeActor(User $trainee, CoachTraineeRelationship $relationship): void
    {
        if (! $trainee->isTrainee() || $trainee->id !== $relationship->trainee_id) {
            throw new AuthorizationException('Forbidden.');
        }
    }

    private function assertPending(CoachTraineeRelationship $relationship): void
    {
        if (! $relationship->isPending()) {
            throw ValidationException::withMessages([
                'status' => 'This join request has already been processed.',
            ]);
        }
    }

    private function assertNoConflictingRequest(int $traineeId, int $coachId, RelationshipType $type): void
    {
        if (CoachTraineeRelationship::query()
            ->where('coach_id', $coachId)
            ->where('trainee_id', $traineeId)
            ->whereIn('status', [RelationshipStatus::PENDING, RelationshipStatus::ACTIVE])
            ->exists()) {
            throw ValidationException::withMessages([
                'coach_id' => 'A request or active assignment already exists for this coach.',
            ]);
        }

        if ($type === RelationshipType::PRIMARY) {
            if (CoachTraineeRelationship::query()
                ->where('trainee_id', $traineeId)
                ->where('relationship_type', RelationshipType::PRIMARY)
                ->where('status', RelationshipStatus::PENDING)
                ->exists()) {
                throw ValidationException::withMessages([
                    'relationship_type' => 'A primary coach request is already pending.',
                ]);
            }

            if (CoachTraineeRelationship::query()
                ->where('trainee_id', $traineeId)
                ->where('relationship_type', RelationshipType::PRIMARY)
                ->where('status', RelationshipStatus::ACTIVE)
                ->whereNull('ended_at')
                ->exists()) {
                throw ValidationException::withMessages([
                    'relationship_type' => 'The trainee already has an active primary coach.',
                ]);
            }
        }
    }

    private function activePairExists(int $coachId, int $traineeId, ?int $ignoreId = null): bool
    {
        return CoachTraineeRelationship::query()
            ->where('coach_id', $coachId)
            ->where('trainee_id', $traineeId)
            ->where('status', RelationshipStatus::ACTIVE)
            ->whereNull('ended_at')
            ->when($ignoreId !== null, fn ($query) => $query->where('id', '!=', $ignoreId))
            ->exists();
    }

    private function activePrimaryExists(int $traineeId, ?int $ignoreId = null): bool
    {
        return CoachTraineeRelationship::query()
            ->where('trainee_id', $traineeId)
            ->where('relationship_type', RelationshipType::PRIMARY)
            ->where('status', RelationshipStatus::ACTIVE)
            ->whereNull('ended_at')
            ->when($ignoreId !== null, fn ($query) => $query->where('id', '!=', $ignoreId))
            ->exists();
    }

    private function rethrowUniqueViolation(QueryException $exception): void
    {
        $message = strtolower($exception->getMessage());

        if (str_contains($message, 'unique') || str_contains($message, 'duplicate key')) {
            throw ValidationException::withMessages([
                'status' => 'A conflicting request or assignment already exists.',
            ]);
        }
    }
}
