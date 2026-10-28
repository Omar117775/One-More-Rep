<?php

namespace App\Support\Concerns;

use App\Models\User;
use Illuminate\Auth\Access\AuthorizationException;

trait AuthorizesCoachAccess
{
    /**
     * Ensure the coach is authorized to access the given trainee.
     * Never trust client-supplied IDs without verification.
     */
    protected function authorizeCoachAccessToTrainee(User $coach, User $trainee): void
    {
        if (! $coach->isCoach() && ! $coach->isSuperAdmin()) {
            throw new AuthorizationException('Forbidden.');
        }

        if (! $trainee->is_active || ! $trainee->isTrainee()) {
            throw new AuthorizationException('Forbidden.');
        }

        if ($coach->isSuperAdmin()) {
            return;
        }

        if (! $coach->isCoaching($trainee)) {
            throw new AuthorizationException('Forbidden.');
        }
    }
}
