<?php

namespace App\Policies;

use App\Models\CoachTraineeRelationship;
use App\Models\User;

class CoachTraineeRelationshipPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->isSuperAdmin();
    }

    public function view(User $user, CoachTraineeRelationship $relationship): bool
    {
        if ($user->isSuperAdmin()) {
            return true;
        }

        return $user->id === $relationship->coach_id || $user->id === $relationship->trainee_id;
    }

    public function create(User $user): bool
    {
        return $user->isTrainee();
    }

    public function approve(User $user, CoachTraineeRelationship $relationship): bool
    {
        return $user->isCoach() && $user->id === $relationship->coach_id;
    }

    public function reject(User $user, CoachTraineeRelationship $relationship): bool
    {
        return $this->approve($user, $relationship);
    }

    public function cancel(User $user, CoachTraineeRelationship $relationship): bool
    {
        return $user->isTrainee() && $user->id === $relationship->trainee_id;
    }

    public function end(User $user, CoachTraineeRelationship $relationship): bool
    {
        return $user->id === $relationship->coach_id || $user->id === $relationship->trainee_id;
    }

    public function delete(User $user, CoachTraineeRelationship $relationship): bool
    {
        return $user->isSuperAdmin();
    }
}
