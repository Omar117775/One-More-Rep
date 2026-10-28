<?php

namespace App\Policies;

use App\Models\TraineeProfile;
use App\Models\User;

class TraineeProfilePolicy
{
    public function view(User $user, TraineeProfile $traineeProfile): bool
    {
        if ($user->isSuperAdmin()) {
            return true;
        }

        if ($user->id === $traineeProfile->user_id) {
            return true;
        }

        if ($user->isCoach()) {
            $trainee = $traineeProfile->user;
            if (! $trainee) {
                return false;
            }

            return $user->isCoaching($trainee);
        }

        return false;
    }

    public function update(User $user, TraineeProfile $traineeProfile): bool
    {
        if ($user->isSuperAdmin()) {
            return true;
        }

        return $user->id === $traineeProfile->user_id;
    }
}
