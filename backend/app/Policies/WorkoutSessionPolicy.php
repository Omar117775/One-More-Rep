<?php

namespace App\Policies;

use App\Models\User;
use App\Models\WorkoutSession;

class WorkoutSessionPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->isCoach() || $user->isTrainee();
    }

    public function view(User $user, WorkoutSession $session): bool
    {
        if ($user->isTrainee() && $session->trainee_id === $user->id) {
            return true;
        }

        if ($user->isCoach()) {
            $trainee = $session->trainee;

            return $trainee !== null && $user->isCoaching($trainee);
        }

        return false;
    }

    public function create(User $user): bool
    {
        return $user->isTrainee();
    }

    public function update(User $user, WorkoutSession $session): bool
    {
        return $user->isTrainee() && $session->trainee_id === $user->id;
    }

    public function delete(User $user, WorkoutSession $session): bool
    {
        return $this->update($user, $session);
    }
}
