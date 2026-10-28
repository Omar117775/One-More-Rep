<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Exercise extends Model
{
    use HasFactory;

    protected $fillable = [
        'created_by',
        'name',
        'muscle_group',
        'equipment',
        'instructions',
        'is_public',
    ];

    protected function casts(): array
    {
        return [
            'is_public' => 'boolean',
        ];
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function dayExercises(): HasMany
    {
        return $this->hasMany(WorkoutDayExercise::class);
    }

    public function workoutSets(): HasMany
    {
        return $this->hasMany(WorkoutSet::class);
    }
}
