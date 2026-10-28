<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class WorkoutProgramDay extends Model
{
    use HasFactory;

    protected $fillable = [
        'workout_program_id',
        'day_number',
        'name',
    ];

    protected function casts(): array
    {
        return [
            'day_number' => 'integer',
        ];
    }

    public function program(): BelongsTo
    {
        return $this->belongsTo(WorkoutProgram::class, 'workout_program_id');
    }

    public function exercises(): HasMany
    {
        return $this->hasMany(WorkoutDayExercise::class, 'workout_program_day_id')->orderBy('sort_order');
    }
}
