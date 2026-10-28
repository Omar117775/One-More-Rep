<?php

namespace App\Policies;

use App\Models\User;

class UserPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->isSuperAdmin();
    }

    public function view(User $user, User $model): bool
    {
        if ($user->isSuperAdmin()) {
            return true;
        }

        if ($user->id === $model->id) {
            return true;
        }

        if ($user->isCoach() && $model->isTrainee()) {
            return $user->isCoaching($model);
        }

        return false;
    }

    public function create(User $user): bool
    {
        return $user->isSuperAdmin();
    }

    public function update(User $user, User $model): bool
    {
        if ($user->isSuperAdmin()) {
            return true;
        }

        return $user->id === $model->id;
    }

    public function assignRole(User $user): bool
    {
        return $user->isSuperAdmin();
    }

    public function updateStatus(User $user): bool
    {
        return $user->isSuperAdmin();
    }
}
