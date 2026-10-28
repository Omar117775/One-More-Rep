<?php

namespace App\Policies;

use App\Models\BodyMeasurement;
use App\Models\User;

class BodyMeasurementPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->isTrainee() || $user->isCoach();
    }

    public function view(User $user, BodyMeasurement $measurement): bool
    {
        if ($user->isTrainee() && $user->id === $measurement->trainee_id) {
            return true;
        }

        if ($user->isCoach()) {
            $trainee = $measurement->trainee;

            return $trainee !== null && $user->isCoaching($trainee);
        }

        return false;
    }

    public function create(User $user): bool
    {
        return $user->isTrainee();
    }

    public function update(User $user, BodyMeasurement $measurement): bool
    {
        return $user->isTrainee() && $user->id === $measurement->trainee_id;
    }

    public function delete(User $user, BodyMeasurement $measurement): bool
    {
        return $this->update($user, $measurement);
    }
}
