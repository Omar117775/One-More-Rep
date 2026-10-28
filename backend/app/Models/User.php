<?php

namespace App\Models;

use App\Enums\RoleName;
use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable implements MustVerifyEmail
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = ['name', 'email', 'password', 'locale', 'timezone'];

    protected $hidden = ['password', 'remember_token'];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'is_active' => 'boolean',
            'last_login_at' => 'datetime',
        ];
    }

    public function roles(): BelongsToMany
    {
        return $this->belongsToMany(Role::class, 'user_roles');
    }

    public function coachProfile(): HasOne
    {
        return $this->hasOne(CoachProfile::class);
    }

    public function traineeProfile(): HasOne
    {
        return $this->hasOne(TraineeProfile::class);
    }

    public function coachingRelationships(): HasMany
    {
        return $this->hasMany(CoachTraineeRelationship::class, 'coach_id');
    }

    public function traineeRelationships(): HasMany
    {
        return $this->hasMany(CoachTraineeRelationship::class, 'trainee_id');
    }

    public function bodyMeasurements(): HasMany
    {
        return $this->hasMany(BodyMeasurement::class, 'trainee_id');
    }

    public function createdExercises(): HasMany
    {
        return $this->hasMany(Exercise::class, 'created_by');
    }

    public function workoutPrograms(): HasMany
    {
        return $this->hasMany(WorkoutProgram::class, 'coach_id');
    }

    public function workoutAssignments(): HasMany
    {
        return $this->hasMany(WorkoutAssignment::class, 'trainee_id');
    }

    public function assignedWorkoutPrograms(): HasMany
    {
        return $this->hasMany(WorkoutAssignment::class, 'assigned_by');
    }

    public function workoutSessions(): HasMany
    {
        return $this->hasMany(WorkoutSession::class, 'trainee_id');
    }

    public function cardioSessions(): HasMany
    {
        return $this->hasMany(CardioSession::class, 'trainee_id');
    }

    public function hasActivePrimaryCoach(): bool
    {
        return $this->traineeRelationships()
            ->where('relationship_type', 'primary')
            ->where('status', 'active')
            ->whereNull('ended_at')
            ->exists();
    }

    public function activePrimaryCoachRelationship(): HasOne
    {
        return $this->hasOne(CoachTraineeRelationship::class, 'trainee_id')
            ->where('relationship_type', 'primary')
            ->where('status', 'active')
            ->whereNull('ended_at');
    }

    public function activeCoachingRelationships(): HasMany
    {
        return $this->hasMany(CoachTraineeRelationship::class, 'coach_id')
            ->where('status', 'active')
            ->whereNull('ended_at');
    }

    public function hasRole(RoleName|string $role): bool
    {
        $roleName = $role instanceof RoleName ? $role->value : $role;
        $this->loadMissing('roles');

        return $this->roles->contains('name', $roleName);
    }

    public function hasAnyRole(array $roles): bool
    {
        foreach ($roles as $role) {
            if ($this->hasRole($role)) {
                return true;
            }
        }

        return false;
    }

    public function isSuperAdmin(): bool
    {
        return $this->hasRole(RoleName::SUPER_ADMIN);
    }

    public function isCoach(): bool
    {
        return $this->hasRole(RoleName::COACH);
    }

    public function isTrainee(): bool
    {
        return $this->hasRole(RoleName::TRAINEE);
    }

    public function isCoaching(User $trainee): bool
    {
        return $this->activeCoachingRelationships()
            ->where('trainee_id', $trainee->id)
            ->exists();
    }
}
