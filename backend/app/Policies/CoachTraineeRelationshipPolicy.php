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
        return $user->isSuperAdmin();
    }

    public function delete(User $user, CoachTraineeRelationship $relationship): bool
    {
        return $user->isSuperAdmin();
    }
}
