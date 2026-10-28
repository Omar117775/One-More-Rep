<?php

namespace App\Policies;

use App\Models\User;
use App\Models\WorkoutAssignment;

class WorkoutAssignmentPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->isCoach() || $user->isTrainee();
    }

    public function view(User $user, WorkoutAssignment $assignment): bool
    {
        if ($user->isTrainee() && $assignment->trainee_id === $user->id) {
            return true;
        }

        if ($user->isCoach()) {
            $assignment->loadMissing(['program', 'trainee']);

            return $assignment->program?->coach_id === $user->id
                && $assignment->trainee !== null
                && $user->isCoaching($assignment->trainee);
        }

        return false;
    }

    public function create(User $user): bool
    {
        return $user->isCoach();
    }

    public function end(User $user, WorkoutAssignment $assignment): bool
    {
        return $this->view($user, $assignment);
    }
}
