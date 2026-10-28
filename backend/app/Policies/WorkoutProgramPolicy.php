<?php

namespace App\Policies;

use App\Enums\Enums\RelationshipStatus;
use App\Enums\Enums\WorkoutAssignmentStatus;
use App\Models\User;
use App\Models\WorkoutProgram;

class WorkoutProgramPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->isCoach();
    }

    public function view(User $user, WorkoutProgram $program): bool
    {
        if ($user->isCoach() && $program->coach_id === $user->id) {
            return true;
        }

        if ($user->isTrainee()) {
            $relationshipActive = $user->traineeRelationships()
                ->where('coach_id', $program->coach_id)
                ->where('status', RelationshipStatus::ACTIVE)
                ->whereNull('ended_at')
                ->exists();

            return $relationshipActive && $program->assignments()
                ->where('trainee_id', $user->id)
                ->where('status', WorkoutAssignmentStatus::ACTIVE)
                ->exists();
        }

        return false;
    }

    public function create(User $user): bool
    {
        return $user->isCoach();
    }

    public function update(User $user, WorkoutProgram $program): bool
    {
        return $user->isCoach() && $program->coach_id === $user->id;
    }

    public function delete(User $user, WorkoutProgram $program): bool
    {
        return $this->update($user, $program);
    }

    public function assign(User $user, WorkoutProgram $program): bool
    {
        return $this->update($user, $program);
    }
}
