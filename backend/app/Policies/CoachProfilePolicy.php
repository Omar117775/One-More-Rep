<?php

namespace App\Policies;

use App\Models\CoachProfile;
use App\Models\User;

class CoachProfilePolicy
{
    public function view(User $user, CoachProfile $coachProfile): bool
    {
        if ($user->isSuperAdmin()) {
            return true;
        }

        if ($user->id === $coachProfile->user_id) {
            return true;
        }

        if ($user->isTrainee()) {
            $coach = $coachProfile->user;
            if (! $coach) {
                return false;
            }

            return $user->activePrimaryCoachRelationship()->where('coach_id', $coach->id)->exists() || $coach->isCoaching($user);
        }

        return false;
    }

    public function update(User $user, CoachProfile $coachProfile): bool
    {
        if ($user->isSuperAdmin()) {
            return true;
        }

        return $user->id === $coachProfile->user_id;
    }
}
