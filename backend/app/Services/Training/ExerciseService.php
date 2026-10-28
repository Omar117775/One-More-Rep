<?php

namespace App\Services\Training;

use App\Enums\Enums\AuditAction;
use App\Enums\Enums\WorkoutAssignmentStatus;
use App\Models\Exercise;
use App\Models\User;
use App\Services\Audit\AuditLogger;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class ExerciseService
{
    public function __construct(private readonly AuditLogger $auditLogger) {}

    public function visibleTo(User $user): Builder
    {
        $query = Exercise::query();

        if ($user->isCoach()) {
            return $query->where(function (Builder $query) use ($user) {
                $query->where('is_public', true)
                    ->orWhere('created_by', $user->id);
            });
        }

        if ($user->isTrainee()) {
            return $query->where(function (Builder $query) use ($user) {
                $query->where('is_public', true)
                    ->orWhereHas('dayExercises.day.program', function (Builder $query) use ($user) {
                        $query->whereHas('assignments', function (Builder $assignmentQuery) use ($user) {
                            $assignmentQuery->where('trainee_id', $user->id)
                                ->where('status', WorkoutAssignmentStatus::ACTIVE);
                        })->whereHas('coach.activeCoachingRelationships', function (Builder $relationshipQuery) use ($user) {
                            $relationshipQuery->where('trainee_id', $user->id);
                        });
                    });
            });
        }

        return $query->whereRaw('1 = 0');
    }

    public function create(User $coach, array $data): Exercise
    {
        return DB::transaction(function () use ($coach, $data) {
            $exercise = Exercise::create([
                ...$data,
                'created_by' => $coach->id,
                'is_public' => $data['is_public'] ?? false,
            ]);

            $this->auditLogger->log($coach, AuditAction::EXERCISE_CREATED->value, $exercise, [
                'muscle_group' => $exercise->muscle_group,
                'equipment' => $exercise->equipment,
                'is_public' => $exercise->is_public,
            ]);

            return $exercise->fresh();
        });
    }

    public function update(User $coach, Exercise $exercise, array $data): Exercise
    {
        return DB::transaction(function () use ($coach, $exercise, $data) {
            $locked = Exercise::query()->lockForUpdate()->findOrFail($exercise->id);
            $this->assertOwned($coach, $locked);

            $locked->fill($data)->save();

            $this->auditLogger->log($coach, AuditAction::EXERCISE_UPDATED->value, $locked, [
                'fields' => array_keys($data),
                'is_public' => $locked->is_public,
            ]);

            return $locked->fresh();
        });
    }

    public function delete(User $coach, Exercise $exercise): void
    {
        DB::transaction(function () use ($coach, $exercise) {
            $locked = Exercise::query()->lockForUpdate()->findOrFail($exercise->id);
            $this->assertOwned($coach, $locked);

            if ($locked->dayExercises()->exists() || $locked->workoutSets()->exists()) {
                throw ValidationException::withMessages([
                    'exercise' => 'This exercise is used by a workout program or session and cannot be deleted.',
                ]);
            }

            try {
                $this->auditLogger->log($coach, AuditAction::EXERCISE_DELETED->value, $locked);
                $locked->delete();
            } catch (QueryException) {
                throw ValidationException::withMessages([
                    'exercise' => 'This exercise is used by a workout program or session and cannot be deleted.',
                ]);
            }
        });
    }

    /**
     * @param  list<int>  $exerciseIds
     */
    public function assertExercisesAvailable(User $coach, array $exerciseIds): void
    {
        $uniqueIds = array_values(array_unique(array_map('intval', $exerciseIds)));
        $available = $this->visibleTo($coach)->whereIn('id', $uniqueIds)->count();

        if ($available !== count($uniqueIds)) {
            throw ValidationException::withMessages([
                'days' => 'One or more exercises are not available to this coach.',
            ]);
        }
    }

    private function assertOwned(User $coach, Exercise $exercise): void
    {
        if ($exercise->created_by !== $coach->id) {
            throw ValidationException::withMessages([
                'exercise' => 'Only the coach who created this exercise can change it.',
            ]);
        }
    }
}
