<?php

namespace App\Policies;

use App\Enums\Enums\WorkoutAssignmentStatus;
use App\Models\Exercise;
use App\Models\User;

class ExercisePolicy
{
    public function viewAny(User $user): bool
    {
        return $user->isCoach() || $user->isTrainee();
    }

    public function view(User $user, Exercise $exercise): bool
    {
        if ($exercise->is_public) {
            return $user->isCoach() || $user->isTrainee();
        }

        if ($user->isCoach() && $exercise->created_by === $user->id) {
            return true;
        }

        if ($user->isTrainee()) {
            return $exercise->dayExercises()
                ->whereHas('day.program', function ($query) use ($user) {
                    $query->whereHas('assignments', function ($assignmentQuery) use ($user) {
                        $assignmentQuery->where('trainee_id', $user->id)
                            ->where('status', WorkoutAssignmentStatus::ACTIVE);
                    })->whereHas('coach.activeCoachingRelationships', function ($relationshipQuery) use ($user) {
                        $relationshipQuery->where('trainee_id', $user->id);
                    });
                })
                ->exists();
        }

        return false;
    }

    public function create(User $user): bool
    {
        return $user->isCoach();
    }

    public function update(User $user, Exercise $exercise): bool
    {
        return $user->isCoach() && $exercise->created_by === $user->id;
    }

    public function delete(User $user, Exercise $exercise): bool
    {
        return $this->update($user, $exercise);
    }
}
