<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class WorkoutProgram extends Model
{
    use HasFactory;

    protected $fillable = [
        'coach_id',
        'name',
        'description',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
        ];
    }

    public function coach(): BelongsTo
    {
        return $this->belongsTo(User::class, 'coach_id');
    }

    public function days(): HasMany
    {
        return $this->hasMany(WorkoutProgramDay::class, 'workout_program_id')->orderBy('day_number');
    }

    public function assignments(): HasMany
    {
        return $this->hasMany(WorkoutAssignment::class, 'workout_program_id');
    }
}
